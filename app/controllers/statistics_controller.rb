class StatisticsController < ApplicationController

  before_filter :authenticate_payer!

  # GET /consumers
  # GET /consumers.json
  def index
    return unless @consumer
    
    allowance = @consumer.allowance[:amount] unless @consumer.allowance[:so_far_accumulated] == 0
    balance = @consumer.balance.to_i 

    if allowance and balance < allowance
      @needle_value = allowance - balance
      @max_value = allowance
    else
      @needle_value = 0
      @max_value = balance
    end

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