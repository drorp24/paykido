class StatisticsController < ApplicationController

  before_filter :authenticate_payer!

  # GET /consumers
  # GET /consumers.json
  def index

    if current_payer.consumers.empty?
      return
    elsif !@consumer
      @consumer = current_payer.consumers.first
    end
        
    @allowance = @consumer.allowance

    allowance = @allowance[:so_far_accumulated].to_i + @allowance[:prev_allowance_acc].to_i 
    balance = @consumer.balance.to_i 

    @min_value = 0
    if allowance > 0
      if balance < allowance
        @needle_value = balance
        @max_value = allowance
      else
        @needle_value = balance
        @max_value = balance
      end        
    elsif allowance == 0
      if balance > 0                      # gifts etc
        @needle_value = balance
        @max_value = balance
      else                                # tests only (should be accounted as old allowance)
        @needle_value = balance
        @min_value = balance
        @max_value = 0
      end        
    end
    
#    starring this is meant to make the payer go to rule page where he will get a similar message
#    if current_payer.rules_require_registration
#      @allowance_for_unregistered = true        # can also happen if registration was cancelled
#      return
#    end

    @allowance_rule = @consumer.allowance_rule
    if current_payer.rules_require_registration or @allowance_rule.nil? or @allowance_rule.initialized? # remove the first if I unstar above
      @no_allowance_defined = true
    elsif @allowance_rule.effective_occurrences == 0
      @allowance_not_effective_yet = true
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