$ ->
  bWizardTabClass = ""
  $(".wizard").each ->
    if $(this).is("#rootwizard")
      bWizardTabClass = "bwizard-steps"
    else
      bWizardTabClass = ""
    wiz = $(this)
    $(this).bootstrapWizard
      onNext: (tab, navigation, index) ->
        index is 1

      onLast: (tab, navigation, index) ->

      onTabClick: (tab, navigation, index) ->

      onTabShow: (tab, navigation, index) ->
        $total = navigation.find("li:not(.status)").length
        $current = index + 1
        $percent = ($current / $total) * 100
        if wiz.find(".bar").length
          wiz.find(".bar").css width: $percent + "%"
          wiz.find(".bar").find(".step-current").html($current).parent().find(".steps-total").html($total).parent().find(".steps-percent").html Math.round($percent) + "%"

        # update status
        wiz.find(".step-current").html $current  if wiz.find(".step-current").length
        wiz.find(".steps-total").html $total  if wiz.find(".steps-total").length
        wiz.find(".steps-complete").html ($current - 1)  if wiz.find(".steps-complete").length

        # mark all previous tabs as complete
        navigation.find("li:not(.status)").removeClass "primary"
        navigation.find("li:not(.status):lt(" + ($current - 1) + ")").addClass "primary"

        # If it's the last tab then hide the last button and show the finish instead
        if $current >= $total
          wiz.find(".pagination").hide()
          wiz.find(".finish_setup").show()
          wiz.find(".finish_setup").removeClass "disabled"
        else
          wiz.find(".pagination").show()
          wiz.find(".finish_setup").hide()

      tabClass: bWizardTabClass
      nextSelector: ".next"
      previousSelector: ".previous"
      firstSelector: ".first"
      lastSelector: ".last"

    wiz.find(".finish").click ->
      alert "Finished!, Starting over!"
      wiz.find("a[data-toggle*='tab']:first").trigger "click"