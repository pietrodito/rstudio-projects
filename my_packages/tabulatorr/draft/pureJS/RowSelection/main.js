//define data array
var tabledata = [
    {id:1, name:"Oli Bob", progress:12, gender:"male", rating:1, col:"red", dob:"19/02/1984", car:1},
    {id:2, name:"Mary May", progress:1, gender:"female", rating:2, col:"blue", dob:"14/05/1982", car:true},
    {id:3, name:"Christine Lobowski", progress:42, gender:"female", rating:0, col:"green", dob:"22/05/1982", car:"true"},
    {id:4, name:"Brendon Philips", progress:100, gender:"male", rating:1, col:"orange", dob:"01/08/1980"},
    {id:5, name:"Margret Marmajuke", progress:16, gender:"female", rating:5, col:"yellow", dob:"31/01/1999"},
    {id:6, name:"Frank Harbours", progress:38, gender:"male", rating:4, col:"red", dob:"12/05/1966", car:1},
];

//Build Tabulator
var table = new Tabulator("#example-table", {
    data:tabledata,
    height:"311px",
    selectableRows:true, //make rows selectable
    autoColumns:true,
});

table.on("rowSelectionChanged", function(data, rows){
  document.getElementById("select-stats").innerHTML = data.length;
});

//select row on "select" button click
document.getElementById("select-row").addEventListener("click", function(){
    table.selectRow(1);
});

//deselect row on "deselect" button click
document.getElementById("deselect-row").addEventListener("click", function(){
    table.deselectRow(1);
});

//select row on "select all" button click
document.getElementById("select-all").addEventListener("click", function(){
    table.selectRow();
});

//deselect row on "deselect all" button click
document.getElementById("deselect-all").addEventListener("click", function(){
    table.deselectRow();
});