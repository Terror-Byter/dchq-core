jQuery ($) ->
  $("#payment_form").submit (e) ->
    $form = $(this)

    # Disable the submit button to prevent repeated clicks
    $form.find("button").prop "disabled", true
    Stripe.createToken $form, stripeResponseHandler

    # Prevent the form from submitting with the default action
    false

  return

stripeResponseHandler = (status, response) ->
  $form = $("#payment_form")
  if response.error

    # Show the errors on the form
    $(".alert.alert-error").remove()
    $form.prepend "<div class='alert alert-error' id='alert alert-error'><button class='close' data-dismiss='alert'>×</button><h4>There was an issue processing this payment:</h4><ul><li>" + response.error.message + "</li></ul></div>"
    $form.find("button").prop "disabled", false
  else

    # token contains id, last4, and card type
    token = response.id

    # Insert the token into the form so it gets submitted to the server
    $form.append $("<input type=\"hidden\" name=\"stripe_card_token\" />").val(token)

    # and re-submit
    $form.get(0).submit()
  return
