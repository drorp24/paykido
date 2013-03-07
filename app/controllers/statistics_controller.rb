class StatisticsController < ApplicationController

  before_filter :authenticate_payer!

  # GET /consumers
  # GET /consumers.json
  def index
    @consumers = current_payer.consumers
  end

  # GET /consumers/1
  # GET /consumers/1.json
  def show

  end

  # GET /consumers/new
  # GET /consumers/new.json
  def new
  end

  # GET /consumers/1/edit
  def edit
  end

  # POST /consumers
  # POST /consumers.json
  def create
  end

  # PUT /consumers/1
  # PUT /consumers/1.json
  def update
  end

  # DELETE /consumers/1
  # DELETE /consumers/1.json
  def destroy
  end

  private



end