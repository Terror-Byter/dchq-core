@module 'Dchq', ->
  @module 'BusinessContact', ->
    @init =->
      $('#tag_list').make_as_taggable('#business_contact_tag_list')

$ ->
  Dchq.BusinessContact.init() if $('#business_contact_tag_list').length
