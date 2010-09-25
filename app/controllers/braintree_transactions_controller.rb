class BraintreeTransactionsController < ApplicationController
  # GET /braintree_transactions
  # GET /braintree_transactions.xml
  def index
    @braintree_transactions = BraintreeTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @braintree_transactions }
    end
  end

  # GET /braintree_transactions/1
  # GET /braintree_transactions/1.xml
  def show
    @braintree_transaction = BraintreeTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @braintree_transaction }
    end
  end

  # GET /braintree_transactions/new
  # GET /braintree_transactions/new.xml
  def new
    @braintree_transaction = BraintreeTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @braintree_transaction }
    end
  end

  # GET /braintree_transactions/1/edit
  def edit
    @braintree_transaction = BraintreeTransaction.find(params[:id])
  end

  # POST /braintree_transactions
  # POST /braintree_transactions.xml
  def create
    @braintree_transaction = BraintreeTransaction.new(params[:braintree_transaction])

    respond_to do |format|
      if @braintree_transaction.save
        flash[:notice] = 'BraintreeTransaction was successfully created.'
        format.html { redirect_to(@braintree_transaction) }
        format.xml  { render :xml => @braintree_transaction, :status => :created, :location => @braintree_transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @braintree_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /braintree_transactions/1
  # PUT /braintree_transactions/1.xml
  def update
    @braintree_transaction = BraintreeTransaction.find(params[:id])

    respond_to do |format|
      if @braintree_transaction.update_attributes(params[:braintree_transaction])
        flash[:notice] = 'BraintreeTransaction was successfully updated.'
        format.html { redirect_to(@braintree_transaction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @braintree_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /braintree_transactions/1
  # DELETE /braintree_transactions/1.xml
  def destroy
    @braintree_transaction = BraintreeTransaction.find(params[:id])
    @braintree_transaction.destroy

    respond_to do |format|
      format.html { redirect_to(braintree_transactions_url) }
      format.xml  { head :ok }
    end
  end
end
