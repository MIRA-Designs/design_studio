# test/controllers/products_controller_test.rb
require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @product = products(:one) # make sure this exists
    @variant = product_variants(:one) # related to @product
  end

  test "should get index" do
    get products_url
    assert_response :success
    # check products header exists
    assert_select "h1", /Products/i
    # check new product button exists
    assert_select "main div a.btn-new[href=?]", new_product_path,
                  text: "➕ New Product", count: 1
  end

  test "should get new" do
    get new_product_url
    assert_response :success
    assert_select "form"
    assert_select "main div a.btn-back[href=?]", products_path,
                  text: /Back to Products/, count: 1
  end

  test "should create product with variant" do
    assert_difference([ "Product.count", "ProductVariant.count" ]) do
      post products_url, params: {
        product: {
          name: "New Product",
          description: "Cool new product",
          brand: "BrandX",
          category: "men",
          rating: 4.0,
          images: [ fixture_file_upload("test/fixtures/files/sample.jpg", "image/jpeg") ],
          product_variant: {
            sku: "SKU123456",
            mrp: "2000.00",
            price: "1800.00",
            discount_percent: "10.00",
            size: "M",
            color: "Black",
            stock_quantity: 20,
            specs: { material: "cotton", fit: "regular" }
          }
        }
      }
    end

    product = Product.last
    variant = product.primary_variant

    assert_redirected_to product_url(product)
    assert_equal "New Product", product.name
    assert_equal "BrandX", product.brand
    assert_equal 1, product.variants.count
    assert_equal "cotton", variant.specs["material"]
  end

  test "should not create product if variant invalid (missing required mrp)" do
    assert_no_difference([ "Product.count", "ProductVariant.count" ]) do
      post products_url, params: {
        product: {
          name: "Bad Product",
          description: "Something",
          brand: "BrandFail",
          category: "women",
          rating: 3.0,
          product_variant: {
            sku: "BADSKU",
            price: "1000.00",
            mrp: nil, # Invalid
            stock_quantity: 10,
            specs: {}
          }
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
    assert_select "h2", @product.brand
    assert_select "h4", @product.name
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
    assert_select "form"
  end

  test "should update product and variant" do
    patch product_url(@product), params: {
      product: {
        name: "Updated Product",
        rating: 4.2,
        product_variant: {
          size: "XL",
          color: "Blue"
        }
      }
    }

    assert_redirected_to product_url(@product)
    @product.reload
    assert_equal "Updated Product", @product.name
    assert_equal 4.2, @product.rating
  end

  test "should not update with invalid variant data" do
    patch product_url(@product), params: {
      product: {
        product_variant: {
          mrp: nil # Invalid
        }
      }
    }

    assert_response :unprocessable_entity
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  test "should enforce unique SKU" do
    duplicate_sku = @variant.sku

    assert_no_difference([ "Product.count", "ProductVariant.count" ]) do
      post products_url, params: {
        product: {
          name: "Dup SKU Product",
          description: "desc",
          brand: "brand",
          category: "kids",
          rating: 4.0,
          product_variant: {
            sku: duplicate_sku, # duplicate
            mrp: "1500.00",
            price: "1300.00",
            stock_quantity: 5,
            specs: {}
          }
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
