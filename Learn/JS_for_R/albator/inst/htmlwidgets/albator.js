HTMLWidgets.widget({

  name: 'albator',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        tab_options = {
          data: x.data,
          ...x.options
        };

        var table = new Tabulator("#" + el.id, tab_options);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
