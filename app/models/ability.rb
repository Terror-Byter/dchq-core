class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role

    when Role::MANAGER
      can :manage, [Brand, Category, StoreProduct, Rental, Rented, RentalPayment], store: { company_id: user.company_id }
      can :manage, [Note, CreditNote, BusinessContact]
      can :manage, [User, GiftCardType, Supplier, SmartList], company_id: user.company_id

      can :manage, Customer do |customer|
        customer.company_id == user.company_id
      end

    when Role::STAFF
      can :read, [Brand, Category, StoreProduct], store: { company_id: user.company_id }
      can :search, [StoreProduct]
      can :manage, [Rental, Rented, RentalPayment], store: { company_id: user.company_id }
      can :read, [GiftCardType, SmartList], company_id: user.company_id
      can :create, Note
      can :update, User, id: user.id
      can :read, CreditNote
    end

  end
end
