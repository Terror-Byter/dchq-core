@module 'Dchq', ->
  @module 'SmartList', ->
    @init =->
      $('.fields select.which').live 'change', (e) ->
        id = $(@).attr('id').replace(/[^\d]/g, '')
        if $(@).val() == 'any'
          showAnyItemFields($(@), id)
        else
          showHowManyFields($(@), id)

      $('.fields select.resource').live 'change', (e) ->
        showAnyItemFields($(@), $(@).attr('id').replace(/[^\d]/g, ''))

      initSelect2Ajax($('.select2-ajax'))

    initSelect2Ajax = (elem) ->
      elem.select2
        minimumInputLength: 1
        ajax:
          url: '/smart_lists/get_values.json'
          dataType: 'json'
          data: (term, page) ->
            q: term
            type: $(@).closest('.row-fluid').find('.resource').val()
          results: (data, page) ->
            results: data
        initSelection: (element, callback) ->
          id = $(element).val()
          if id != '' && id != '0.0'
            $.ajax('/smart_lists/get_values.json',
              data:
                init_id: id
                type: $(element).data('input-type')
              dataType: 'json'
            ).done (data) ->
              callback data



    showHowManyFields = (elem, new_id) ->
      elem.closest('.row-fluid').find('.item-type').html($("div[data-id=product_list]:last").html().replace(/new_smart_list_conditions/g, new_id))
      elem.closest('.row-fluid').find('.item-type .span12').addClass('select2-ajax')
      initSelect2Ajax(elem.closest('.row-fluid').find('.item-type .span12.select2-ajax'))

    showAnyItemFields = (elem, new_id) ->
      elem.closest('.row-fluid').find('.item-type').html($('div[data-id=any_item]:last').html().replace(/new_smart_list_conditions/g, new_id))
      elem.closest('.row-fluid').find('select.which').val('any')

$ ->
  Dchq.SmartList.init() if $('body.smart-lists').length
