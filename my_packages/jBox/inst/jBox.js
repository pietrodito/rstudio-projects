Shiny.addCustomMessageHandler(
  type = 'send-notice', function(message){
    new jBox('Notice', {
      content: message
    })
  }
);