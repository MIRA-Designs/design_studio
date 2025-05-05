class ProductsController < ApplicationController
  include Pagy::Backend
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @pagy, @products = pagy(Product.all)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @variant = @product.variants.build
  end

  # GET /products/1/edit
  def edit
    @variant = @product.primary_variant
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params.except(:product_variant))
    @variant = @product.variants.build(product_params[:product_variant])

    ActiveRecord::Base.transaction do
      if @product.save
        # Rollback if any variant is invalid
        raise ActiveRecord::Rollback if @variant.invalid?
      else
        raise ActiveRecord::Rollback
      end
    end

    respond_to do |format|
      if @product.persisted?
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          errors = {
            product: @product.errors,
            product_variants: @variant.errors
          }
          render json: errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    # Assign attributes but don’t persist yet
    @product.assign_attributes(product_params.except(:product_variant, :images))
    @variant = @product.primary_variant

    ActiveRecord::Base.transaction do
      if @product.save
        @product.process_images(params[:product][:images])

        # Handle associated variants
        if product_params[:product_variant].present?
          @variant.assign_attributes(product_params[:product_variant])
          unless @variant.save
            # Rollback if any variant is invalid
            raise ActiveRecord::Rollback
          end
        end
      else
        raise ActiveRecord::Rollback
      end
    end

    respond_to do |format|
      if @product.saved_changes.any?
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def delete_image
    @product = Product.find(params[:product_id])
    @image = @product.images.find(params[:image_id])
    @image_id = @image.id

    @image.purge

    respond_to do |format|
      format.html { redirect_to edit_product_path(@product), notice: "Image was successfully removed." }
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(
        :name, :description, :brand, :category, :rating, images: [],
        product_variant: [ :sku, :mrp, :price, :discount_percent, :size, :color, :stock_quantity, specs: {} ]
      )
    end
end
