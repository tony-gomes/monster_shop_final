require 'rails_helper'

RSpec.describe 'As a user' do
  before(:each) do
    @merchant_store = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @merchant1 = @merchant_store.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
    @competitor = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

    @ogre = @merchant_store.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.00, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )
    @hippo = @competitor.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50.00, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )

    @discount1 = @merchant_store.discounts.create!(percentage: 5, quantity: 2)
    @discount2 = @merchant_store.discounts.create!(percentage: 10, quantity: 3)
    @discount3 = @merchant_store.discounts.create!(percentage: 25, quantity: 5)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant1)
  end

  describe 'When a merchant has a bulk discount on their items' do
    context 'And a I add an item to my shopping cart' do
      it 'I see the discount reflected in my subtotal' do
        visit item_path(@ogre)
        click_button 'Add to Cart'

        visit item_path(@hippo)
        click_button 'Add to Cart'

        expect(page).to have_content("Cart: 2")

        visit '/cart'

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: $#{@ogre.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{@ogre.price}")
          expect(page).to have_content("Sold by: #{@merchant_store.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@merchant_store.name)
        end

        within "#item-#{@ogre.id}" do
          click_button('More of This!')
        end

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: $#{@ogre.price}")
          expect(page).to have_content("Quantity: 2")
          ogre_discount_price = (@ogre.price * 2) - ((@ogre.price * 2) * 0.05)
          expect(page).to have_content("Subtotal: $#{ogre_discount_price}")
          expect(page).to have_content("You get a #{@discount1.percentage}% bulk discount")
        end

        within "#item-#{@ogre.id}" do
          click_button('Less of This!')
        end

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: $#{@ogre.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{@ogre.price}")
        end

        within "#item-#{@hippo.id}" do
          expect(page).to have_link(@hippo.name)
          expect(page).to have_content("Price: $#{@hippo.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{@hippo.price}")
          expect(page).to have_content("Sold by: #{@competitor.name}")
          expect(page).to have_css("img[src*='#{@hippo.image}']")
          expect(page).to have_link(@competitor.name)
        end

        within "#item-#{@ogre.id}" do
          click_button('More of This!')
          click_button('More of This!')
          click_button('More of This!')
          click_button('More of This!')
        end

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: $#{@ogre.price}")
          expect(page).to have_content("Quantity: 5")
          expect(page).to have_content("Subtotal: $75.00")
          expect(page).to have_content("You get a #{@discount3.percentage}% bulk discount")
        end

        within "#item-#{@ogre.id}" do
          click_button('Less of This!')
          click_button('Less of This!')
          click_button('Less of This!')
          click_button('Less of This!')
        end

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: $#{@ogre.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{@ogre.price}")
          expect(page).to have_content("Sold by: #{@merchant_store.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@merchant_store.name)
        end

        within "#item-#{@hippo.id}" do
          expect(page).to have_link(@hippo.name)
          expect(page).to have_content("Price: $#{@hippo.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{@hippo.price}")
          expect(page).to have_content("Sold by: #{@competitor.name}")
          expect(page).to have_css("img[src*='#{@hippo.image}']")
          expect(page).to have_link(@competitor.name)
        end
      end
    end
  end
end
