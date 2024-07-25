var _x;
var _y;

var _current_row_selection_data;
var _current_row_selection_rows;

function shorten_long_module_id(id) {
  return id.replace("-not_matchable_id_we_need_to_remove", "");
}

HTMLWidgets.widget({

  name: 'tabulator',
  type: 'output',

  factory: function (el, width, height) {

    return {

      renderValue: function (x) {

        let autoDefinitionsCallbackActions = [];

        setupHeaderMenu(el, x, autoDefinitionsCallbackActions);
        setupCellContextMenu(el, x, autoDefinitionsCallbackActions);

        attachAutoColumnsCallbackActions(x, autoDefinitionsCallbackActions);

        tab_options = {
          data: x.data,
          ...x.options
        };

        var table = new Tabulator("#" + el.id, tab_options);

        addCellClickEvent(el, table);

        addRowSelectionChangedEvent(el, table);

        addSelectorEvents(el, table);

        //
        //        function extractColumnsNames(columns) {
        //          return _.map(columns, col => { return col.getField() });
        //        }
        //
        //        function addColumnMovedEvent() {
        //          table.on("columnMoved", function (column, columns) {
        //            Shiny.setInputValue(
        //              el.id + "_column_moved",
        //              extractColumnsNames(columns),
        //              { priority: 'event' } // Needed to trigger event even if value (click_event_to_R) does not change!
        //            );
        //          });
        //        }
        //
        //        addColumnMovedEvent();

      },

      resize: function (width, height) { }

    };
  }
});

function addSelectorEvents(el, table) {

  Shiny.addCustomMessageHandler(
    type = 'select-all', function (message) {
      table.selectRow();
    }
  );

  Shiny.addCustomMessageHandler(
    type = 'deselect-all', function (message) {
      table.deselectRow();
    }
  );

  Shiny.addCustomMessageHandler(
    type = 'selection-ok', function (message) {


      Shiny.setInputValue(
        shorten_long_module_id(el.id) +
        "_row_selection_confirmed_data:rowSelection.class",
        _current_row_selection_data,
        { priority: 'event' }
      );

      Shiny.setInputValue(
        shorten_long_module_id(el.id) +
        "_row_selection_confirmed_row_numbers",
        _current_row_selection_rows,
        { priority: 'event' }
      );
    }
  );

}




function attachAutoColumnsCallbackActions(x, autoDefinitionsCallbackActions) {

  x.options.autoColumnsDefinitions = function (definitions) {
    for (const action of autoDefinitionsCallbackActions) {
      if (action !== null) {
        definitions.forEach((column) => {
          column[action.columnProperty] = action.columnValue;
        });
      }
    }
    return definitions;
  };

}


function setupHeaderMenu(el, x, autoDefinitionsCallbackActions) {

  let headerMenu = createHeaderMenu(el, x);

  if (headerMenu.length > 0) {
    if (autoColumns(x)) {
      autoDefinitionsCallbackActions.push(
        { columnProperty: "headerMenu", columnValue: headerMenu }
      )
    } else {
      attachPropertyToColumns("headerMenu", headerMenu, x);
    }
  }

}

function createHeaderMenu(el, x) {
  return _.zip(x.headerMenuItems, x.headerMenuEvents).map((elt) => {
    return {
      label: elt[0],
      action: function (e, column) {
        Shiny.setInputValue(
          el.id + "_header_menu_" + elt[1],
          column.getDefinition(),
          { priority: 'event' } // Needed to trigger event even if value does not change!
        );
      }
    }
  });
}

function setupCellContextMenu(el, x, autoDefinitionsCallbackActions) {

  let contextMenu = createCellContextMenu(el, x);

  if (contextMenu.length > 0) {
    if (autoColumns(x)) {
      autoDefinitionsCallbackActions.push(
        { columnProperty: "contextMenu", columnValue: contextMenu }
      )
    } else {
      attachPropertyToColumns("contextMenu", contextMenu, x);
    }
  }
}

function createCellContextMenu(el, x) {
  return _.zip(x.cellContextMenuItems, x.cellContextMenuEvents).map((elt) => {
    return {
      label: elt[0],
      action: function (e, cellDetails) {
        _x = cellDetails;
        Shiny.setInputValue(
          el.id + "_context_menu_" + elt[1],
          constructClickEventForR(cellDetails),
          { priority: 'event' } // Needed to trigger event even if value (click_event_to_R) does not change!
        );
      }
    }
  });
}

function autoColumns(x) {
  return Object.keys(x.options).includes("autoColumns") & x.options.autoColumns;
}

function attachPropertyToColumns(columnProperty, columnValue, x) {
  function rec_helper(c) {
    if (Array.isArray(c)) {
      c.map(o => rec_helper(o));
    } else {
      var keys = Object.keys(c);
      if (keys.includes("title") & !keys.includes("columns")) {
        c[columnProperty] = columnValue;
      }
      if (keys.includes("columns")) {
        rec_helper(c.columns);
      }
    }
  }
  rec_helper(x.options.columns);
}

function addRowSelectionChangedEvent(el, table) {

  // TODO add internal state <=> current selection
  // TODO send current selection when message OK is sent

  table.on("rowSelectionChanged", function (data, rows, selected, deselected) {

    _current_row_selection_data = data;
    _current_row_selection_rows = rows.map(x => x._row.position);

    Shiny.setInputValue(
      shorten_long_module_id(el.id) +
      "_row_selection_changed_data:rowSelection.class",
      data,
      { priority: 'event' }
    );


    Shiny.setInputValue(
      shorten_long_module_id(el.id) +
      "_row_selection_changed_row_numbers",
      _current_row_selection_rows,
      { priority: 'event' }
    );
  });

}

function constructClickEventForR(cell) {
  return {
    value: cell.getValue(),
    row_number: cell.getRow().getPosition(),
    column_name: cell.getField(),
  };
}

function addCellClickEvent(el, table) {
  table.on("cellClick", function (click_event, cell_details) {
    Shiny.setInputValue(
      shorten_long_module_id(el.id) +
      "_cell_clicked",
      constructClickEventForR(cell_details),
      { priority: 'event' } // Needed to trigger event even if value (click_event_to_R) does not change!
    );
  });
}

