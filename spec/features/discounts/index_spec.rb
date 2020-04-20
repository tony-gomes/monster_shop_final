require 'rails_helper'

RSpec.describe 'As a merchant' do
  before(:each) do
    @merchant_store = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @merchant1 = @merchant_store.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')

    @ogre = @merchant_store.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
    @giant = @merchant_store.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
    @hippo = @merchant_store.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
    @dino = @merchant_store.items.create!(name: 'Dinosaur', description: "I'm a Dinosaur!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
    @bigfoot = @merchant_store.items.create!(name: 'Bigfoot', description: "I'm really a Bigfoot!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )

    @discount1 = @merchant_store.discounts.create!(percentage: 5, quantity: 2)
    @discount2 = @merchant_store.discounts.create!(percentage: 10, quantity: 3)
    @discount3 = @merchant_store.discounts.create!(percentage: 25, quantity: 5)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant1)
  end

  describe 'When I visit my dashboard I see a link to my Discounts' do
    context 'when I click the Discounts link' do
      it 'I am sent to the Discounts index page & see a list of Discounts' do
        visit "/merchant"

        expect(current_path).to eql("/merchant")
        expect(page).to have_link(@merchant_store.name)

        click_link "Discounts"

        expect(current_path).to eql("/merchant/discounts")

        expect(page).to have_content("All Discounts:")

        within("#discount-#{@discount1.id}") do
          expect(page).to have_content("Percentage: 5%")
          expect(page).to have_content("Quantity: 2")
        end

        within("#discount-#{@discount2.id}") do
          expect(page).to have_content("Percentage: 10%")
          expect(page).to have_content("Quantity: 3")
        end

        within("#discount-#{@discount3.id}") do
          expect(page).to have_content("Percentage: 25%")
          expect(page).to have_content("Quantity: 5")
        end
      end
    end

    describe 'On the Discounts index page I see a form to add new discounts' do
      context 'when I add valid discount criteria & click submit' do
        it 'I am redirected back to the index page & I see it in my list' do
          visit "/merchant/discounts"

          expect(page).to have_content("Add New Discount:")

          expect(page).to have_css(".add_discount_form")
          fill_in :percentage, with: 30
          fill_in :quantity, with: 7
          click_button "Submit"

          within("#discount-#{Discount.last.id}") do
            expect(page).to have_content("Percentage: #{Discount.last.percentage}%")
            expect(page).to have_content("Quantity: #{Discount.last.quantity}")
          end

          expect(Discount.last.percentage).to eql(30)
          expect(Discount.last.quantity).to eql(7)
        end
      end
    end

    describe 'On the Discounts index page each discount has a delete link' do
      context 'And when I click it I am redirected back to the index page' do
        it 'And I no longer see the discount in the list of discounts' do
          visit "/merchant/discounts"

          expect(page).to have_content("All Discounts:")

          within("#discount-#{@discount1.id}") do
            expect(page).to have_content("Percentage: 5%")
            expect(page).to have_content("Quantity: 2")
            expect(page).to have_link("Delete Discount")
          end

          within("#discount-#{@discount2.id}") do
            expect(page).to have_content("Percentage: 10%")
            expect(page).to have_content("Quantity: 3")
            expect(page).to have_link("Delete Discount")
            click_link "Delete Discount"
          end

          expect(page).to have_no_css("#discount-#{@discount2.id}")

          within("#discount-#{@discount3.id}") do
            expect(page).to have_content("Percentage: 25%")
            expect(page).to have_content("Quantity: 5")
            expect(page).to have_link("Delete Discount")
          end
        end
      end

      describe 'On the Discounts index page each discount has an udpate link' do
        context 'And when I click it I am taken to a form to update discount' do
          it 'When I submit I am redirected back to the discounts page' do
            visit "/merchant/discounts"

            expect(page).to have_content("All Discounts:")

            within("#discount-#{@discount1.id}") do
              expect(page).to have_content("Percentage: 5%")
              expect(page).to have_content("Quantity: 2")
              expect(page).to have_link("Update Discount")
              expect(page).to have_link("Delete Discount")
            end

            within("#discount-#{@discount2.id}") do
              expect(page).to have_content("Percentage: 10%")
              expect(page).to have_content("Quantity: 3")
              expect(page).to have_link("Update Discount")
              expect(page).to have_link("Delete Discount")
              click_link "Update Discount"
            end

            expect(current_path).to eql("/merchant/discount/update")

            fill_in :percentage, with: 15
            click_button "Submit"

            within("#discount-#{@discount2.id}") do
              expect(page).to have_content("Percentage: 15%")
              expect(page).to have_content("Quantity: 3")
              expect(page).to have_link("Update Discount")
              expect(page).to have_link("Delete Discount")
              click_link "Update Discount"
            end

            within("#discount-#{@discount3.id}") do
              expect(page).to have_content("Percentage: 25%")
              expect(page).to have_content("Quantity: 5")
              expect(page).to have_link("Update Discount")
              expect(page).to have_link("Delete Discount")
            end
          end
        end
      end
    end
  end
end
