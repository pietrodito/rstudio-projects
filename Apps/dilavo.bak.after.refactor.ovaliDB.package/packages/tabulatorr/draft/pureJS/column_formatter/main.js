var tabledata = [
    {id:1, name:"Oli Bob", progress:12, gender:"male", rating:1, col:"red", dob:"19/02/1984", car:1},
    {id:2, name:"Mary May", progress:1, gender:"female", rating:2, col:"blue", dob:"14/05/1982", car:true},
    {id:3, name:"Christine Lobowski", progress:42, gender:"female", rating:0, col:"green", dob:"22/05/1982", car:"true"},
    {id:4, name:"Brendon Philips", progress:100, gender:"male", rating:1, col:"orange", dob:"01/08/1980"},
    {id:5, name:"Margret Marmajuke", progress:16, gender:"female", rating:5, col:"yellow", dob:"31/01/1999"},
    {id:6, name:"Frank Harbours", progress:38, gender:"male", rating:4, col:"red", dob:"12/05/1966", car:1},
];


//Generate print icon
var printIcon = function(cell, formatterParams){ //plain text value
    return "<i class='fa fa-print'></i>";
};

//Build Tabulator
var table = new Tabulator("#example-table", {
    data:tabledata,
    layout:"fitColumns",
    rowFormatter:function(row){
        if(row.getData().col == "blue"){
            row.getElement().style.backgroundColor = "#1e3b20";
        }
    },
    columns:[
    {formatter:"rownum", hozAlign:"center", width:40},
    {formatter:printIcon, width:40, hozAlign:"center", cellClick:function(e, cell){alert("Printing row data for: " + cell.getRow().getData().name)}},
    {title:"Name", field:"name", width:150, formatter:function(cell, formatterParams){
       var value = cell.getValue();
        if(value.indexOf("o") > 0){
            return "<span style='color:#3FB449; font-weight:bold;'>" + value + "</span>";
        }else{
            return value;
        }
    }},
    {title:"Progress", field:"progress", formatter:"progress", formatterParams:{color:["#00dd00", "orange", "rgb(255,0,0)"]}, sorter:"number", width:100},
    {title:"Rating", field:"rating", formatter:"star", formatterParams:{stars:6}, hozAlign:"center", width:120},
    {title:"Driver", field:"car", hozAlign:"center", formatter:"tickCross", width:50},
    {title:"Col", field:"col" ,formatter:"color", width:50},
    {title:"Line Wraping", field:"lorem" ,formatter:"textarea"},
    {formatter:"buttonCross", width:30, hozAlign:"center"}
    ],
});