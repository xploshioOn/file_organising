class DocumentsController < ApplicationController
  # validates that the query has the right format
  # tag names separated by white spaces and starting
  # with + or -. and that we have at least a positive one
  before_action :query_format, only: [:search]

  def create
    @document = Document.new(document_params)
    # assing tags, depending if its a new one
    # or associate an existing one
    assign_tags(params[:tags])
    # we have some nested resources to make validations work
    # on both, documents and tags
    if @document.save
      render json: @document.as_json(only: [:uuid]), status: :created
    else
      render json: @document.errors, status: :unprocessable_entity
    end
  end

  def search
    # ask for search results with query from user
    @records = results(params[:tag_search_query], params[:page])
    # if there are no results, we finish here
    if @total == 0
      render json: {message: "No results for this query"}, status: :ok
    elsif out_of_bounds?(params[:page])
      render json: {message: "page number is out of bounds"}, status: :ok
    else
      # if we have results, we ask for related tags
      @related_tags = Tag.by_documents(@records.map {|r| r.id}).exclude(@add).count_by_name
      render json: {
        total_records: @total,
        related_tags: @related_tags,
        records: @records.select(:name, :uuid).as_json(except: :id)
      }, status: :ok
    end
  end

  private

  # params with nested, to create tags and document_tags
  # directly if needed
  def document_params
    params.permit(:name, :tags,
      tags_attributes: [:id, :name],
      document_tags_attributes: [:id, :tag_id, :document_id])
  end

  # this takes all tags for a new file
  # and add it for nesting, if it's a new one
  # or if we need to associate a created one
  def assign_tags(tags)
    if (params[:tags].present?) && (params[:tags].is_a? Array)
      params[:tags].each do |tag|
        @tag = Tag.find_or_initialize_by(name: tag)
        if @tag.new_record?
          @document.tags.build(name:tag)
        else
          @document.document_tags.build(tag_id: @tag.id)
        end
      end
    end
  end

  # validate that the query has certain format
  def query_format
    query = params[:tag_search_query]
    unless valid_query?(query)
      render json: {message: "Invalid search query, it needs to be formated as eg. +tag1 -tag2"}, status: :ok and return
    end
    if get_tag_names(query, "+").size < 1
      render json: {message: "Invalid search query, it needs to have at least one positive tag"}, status: :ok and return
    end
  end

  # query to database depending on query string
  # from params
  def results(tags, page)
    @add = get_tag_names(tags, "+")
    remove = get_tag_names(tags, "-")
    documents = Document.with_all_specified_tags(@add)
    if remove.size > 0
      documents = documents.merge(Document.without_tags(remove))
    end
    @total = documents.count.keys.count
    documents.paginate(page.to_i)
  end

  # return name tags from query string
  # depeding on + or -
  def get_tag_names(tags, sign)
    tags.scan(/[#{sign}](\w+)/).flatten
  end

  # we validate the complete query string
  # to match the format of tags separated by
  # white spaces and starting with + or -
  def valid_query?(query)
    return true if (query =~ /\A(?:\s?[+-][a-zA-Z\d]+\s?)+\z/)
  end

  # to check if page number is out of bounds
  def out_of_bounds?(page)
    page.to_i > ((@total.to_f / 10).ceil)
  end

end
