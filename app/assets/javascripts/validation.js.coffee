@module 'Dchq', ->
  @module 'Validation', ->
    wrapForm = (form)-> # TODO: maybe add this to Object.prototype
      if form.jquery is undefined then $(form) else form

    @formValid = (form)->
      form = wrapForm(form)
      formId = form.attr('id')
      # backup and set our values
      inputTagBak = ClientSideValidations.forms[formId].input_tag
      ClientSideValidations.forms[formId].input_tag = '<span class="noop"><span id="input_tag" /></span>'
      labelTagBak = ClientSideValidations.forms[formId].label_tag
      ClientSideValidations.forms[formId].label_tag = '<span class="noop"><label id="label_tag" /></span>'
      # validate form
      form_validators = ClientSideValidations.forms[formId].validators
      valid = form.isValid(form_validators)
      # restore old values
      ClientSideValidations.forms[formId].input_tag = inputTagBak
      ClientSideValidations.forms[formId].label_tag = labelTagBak
      # return value
      valid

    @highlightFirstError = (form)->
      form = wrapForm(form)
      form.find(':invalid').first().focus()