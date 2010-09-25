class PaypalTransactionsController < ApplicationController
  # GET /paypal_transactions
  # GET /paypal_transactions.xml
  def index
    @paypal_transactions = PaypalTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @paypal_transactions }
    end
  end

  # GET /paypal_transactions/1
  # GET /paypal_transactions/1.xml
  def show
    @paypal_transaction = PaypalTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @paypal_transaction }
    end
  end

  # GET /paypal_transactions/new
  # GET /paypal_transactions/new.xml
  def new
    @paypal_transaction = PaypalTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @paypal_transaction }
    end
  end

  # GET /paypal_transactions/1/edit
  def edit
    @paypal_transaction = PaypalTransaction.find(params[:id])
  end

  # POST /paypal_transactions
  # POST /paypal_transactions.xml
  def create
    @paypal_transaction = PaypalTransaction.new(params[:paypal_transaction])

    respond_to do |format|
      if @paypal_transaction.save
        flash[:notice] = 'PaypalTransaction was successfully created.'
        format.html { redirect_to(@paypal_transaction) }
        format.xml  { render :xml => @paypal_transaction, :status => :created, :location => @paypal_transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @paypal_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /paypal_transactions/1
  # PUT /paypal_transactions/1.xml
  def update
    @paypal_transaction = PaypalTransaction.find(params[:id])

    respond_to do |format|
      if @paypal_transaction.update_attributes(params[:paypal_transaction])
        flash[:notice] = 'PaypalTransaction was successfully updated.'
        format.html { redirect_to(@paypal_transaction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @paypal_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /paypal_transactions/1
  # DELETE /paypal_transactions/1.xml
  def destroy
    @paypal_transaction = PaypalTransaction.find(params[:id])
    @paypal_transaction.destroy

    respond_to do |format|
      format.html { redirect_to(paypal_transactions_url) }
      format.xml  { head :ok }
    end
  end
end
