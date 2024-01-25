var tabledata = [
    {id:1, name:"Oli Bob"           , progress:12  },
    {id:2, name:"Mary May"          , progress:1   },
    {id:3, name:"Christine Lobowski", progress:42  },
    {id:4, name:"Brendon Philips"   , progress:100 },
    {id:5, name:"Margret Marmajuke" , progress:16  },
    {id:6, name:"Frank Harbours"    , progress:38  },
];


//Generate print icon
var printIcon = function(cell, formatterParams){ //plain text value
    return "<i class='fa fa-print'></i>";
};

var green_if_contains_o = function(cell, formatterParams) {
       var value = cell.getValue();
        if(value.indexOf("o") > 0){ // if the name contains the letter 'o'
            return "<span style='color:#3FB449; font-weight:bold;'>" + value + "</span>";
        }else{
            return value;
        }
}

var green_if_too_high = function(cell, formatterParams) {

    var colored_text = function(color, text) {
            return "<span style='color:" + color + "; font-weight:bold;'>" + text + "</span>";
    }
       var value = cell.getValue();

        if(value < formatterParams.threshold){ // if the name contains the letter 'o'
            return colored_text(formatterParams.color[0], value);
        }else{
            return colored_text(formatterParams.color[1], value);
        }
}

//Build Tabulator
var table = new Tabulator("#example-table", {
    data:tabledata,
    layout:"fitColumns",
    columns:[
    {formatter:printIcon, width:40, hozAlign:"center", cellClick:function(e, cell){alert("Printing row data for: " + cell.getRow().getData().name)}},
    {title:"Name", field:"name", width:150, formatter:green_if_contains_o },
    {title:"Progress", field:"progress", formatter:green_if_too_high, formatterParams:{type:"one threshold", threshold:40, color:["green", "red"]}, width:100},
    ],
});