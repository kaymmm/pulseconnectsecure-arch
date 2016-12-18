/**
 * @license Copyright 2010-2015 Pulse Secure, LLC. All rights reserved.
 * This file contains Confidential Trade Secrets of Pulse Secure, LLC.
 * This file is subject to the terms of the Non-Disclosure Agreement between
 * Pulse Secure and the recipient. This file is provided for evaluation only
 * unless further uses are permitted by a License Agreement between Pulse
 * Secure and the recipient. All other use is strictly prohibited.
 */

var numConnections=1;
var g_edit_connNum = -1;
var g_active_connName = "";

function raiseAlert (alertMessage)
{
    customAlert(alertMessage);
}
function raiseUIClosureAlert ()
{
    var msg = "Closing the UI will terminate the VPN session.\nDo you want to continue?";
    bootbox.confirm(msg, function(result) {
        if (result == true) {
            var message = {};
            message['command'] = "closeUI";
            console.log(JSON.stringify(message));
        }
    });
}

function AddConnectionToTable(title, baseurl, editConnNum, storeConnections)
{
    var connAlreadyExists = false;
    if (editConnNum == -1 || !editConnNum || editConnNum == "(null)") {
        $("#mylistgroup li").each(function(){
            var connName = $(this).attr('Name');
            if (connName == title) {
                customAlert("Connection "+title+" already exists");
                connAlreadyExists = true;
                return;
            }
        });
    }
    if (connAlreadyExists == false) {
        $('.list-group').find('.active').removeClass('active');
        $("#mylistgroup").append("<div class='listrow' data = 'test' id = 'test'>\
        			<li href='#' class='list-group-item active col-xs-12' id='ConnectionName' Name='" + title +"' BaseUrl='" +baseurl+"' connNum = '"+numConnections+"'> \
        			<button \
        			type='button' class='col-xs-1 btn btn-default btn-xs' data-toggle='collapse' data-target='#collapseExample" +numConnections+"' aria-expanded='true' aria-controls='collapseExample' onclick='collapseTest(this)'><span class='glyphicon glyphicon-chevron-down'></span></button>\
        			<div class='col-xs-7'>"+title+"</div>\
        			<div class='col-xs-4'>\
        			<button \
        			type='button' class='btn btn-default btn-xs' id='Connect"+numConnections+"' onclick='startVpn(this)'>&nbspConnect&nbsp</button>\
        			</div>\
        			</li>\
        			<div id='collapseExample" +numConnections+"' class='collapse' style='background-color:lightgray; border-radius: 10px 10px 10px 10px;'>\
        			</div>\
        			</div>");
        numConnections++;
        if (editConnNum != -1) {
            $("#mylistgroup li").each(function(){
                var connNum = $(this).attr('connNum');
                if (connNum == editConnNum) {
                    $(this).parent().remove();
                }
            });
        }
        
        if (storeConnections) {
            writeConnectionsToStore();
        }
    }
}

function writeConnectionsToStore()
{
    var connectionsStr = "WriteConnectionsToStore,";
    var message = {};
    var connDetails = {};
    var firstEntry = true;

    if ($("#mylistgroup li").length > 0) {
        $("#mylistgroup li").each(function(){
            message = {};
            connDetails = {};
            var title = $(this).attr('Name');
            var baseUrl = $(this).attr('BaseUrl');
            connDetails['connName'] = title;
            connDetails['baseUrl'] = baseUrl;
            message['command'] = "WriteConnectionsToStore";
            if (firstEntry) {
                message['firstEntry'] = "y";
                firstEntry = false;
            } else {
                message['firstEntry'] = "n";
            }
            message['connDetails'] = JSON.stringify(connDetails);
            console.log(JSON.stringify(message));
        });
    } else {
        message['command'] = "WriteConnectionsToStore";
        message['firstEntry'] = "y";
        message['connDetails'] = "";
        console.log(JSON.stringify(message));
    }
}

var timerVar = [];
var isConnected = [];
function collapseTest(el)
{
    var baseUrl = $(el).parent().attr('BaseUrl');
    var id =  $(el).parent().attr('connNum');
    var title =  $(el).parent().attr('Name');
    var message = {};
    message['command'] = "ShowCollapseScreen";
    message['connName'] = title;
    message['baseUrl'] = baseUrl;
    message['connNum'] = id;
    
    console.log(JSON.stringify(message));

}

function JSSignal(cmd) {
    console.log(cmd);
}

function AddCollapseData(connStatus, baseUrl, id, title, complianceStatus)
{
    if (connStatus == "Connected") {
        isConnected[id] = 1;
    } else {
        isConnected[id] = 0;
    }   
    var collapseEntry = document.getElementById("collapseExample" + id);
    collapseEntry.innerHTML="<div class='col-xs-12'> \
                            <div class='col-xs-1'></div>\
                            Status : "+connStatus+"\
                            <br><div class='col-xs-1'></div>\
                            BaseUrl: "+baseUrl+"\
                            <br><div class='col-xs-1'></div>\
                            Compliance: "+complianceStatus+"\
                            </div>";
    var connectButton = document.getElementById("Connect" + id);
    if (isConnected.length < id || isConnected[id] == 0) {
        connectButton.innerHTML = "&nbspConnect&nbsp";
        g_active_connName = "";
    } else if (isConnected[id] == 1){
        //clearInterval(timerVar[id]);
        //timerVar[id] = 0;
        g_active_connName = title;
        connectButton.innerHTML = "Disconnect";
    }
}

function AdvancedOptions(el)
{
    var message = {};
    message['command'] = "AdvancedOptions";
    
    console.log(JSON.stringify(message));
}

$('#mylistgroup').on('click','.list-group-item', function(e) {
	var $this = $(this);
    $('.list-group').find('.active').removeClass('active');
    $this.addClass('active');
});

$("#configFormId").submit(function (e) {
    var $name = $(document.configForm.inputName1);
    var $url =  $(document.configForm.inputUrl1);

    var $urlEncoded =  encodeURI($url.val());
    var res = $urlEncoded.match(/^https/);
    if (res == null) {
        $urlEncoded = $urlEncoded.replace(/^/, 'https://');
    }
    var message = "ConfigOK,'" + $name.val() + "','" + $urlEncoded +"',"+g_edit_connNum;
    var message = {};
    message['command'] = "ConfigOK";
    message['connName'] = $name.val();
    message['baseUrl'] = $urlEncoded;
    message['connNum'] = g_edit_connNum;
    
    console.log(JSON.stringify(message));
    g_edit_connNum = -1;
});

function connDisconnected(connNum)
{
    isConnected[connNum] = 0;
    clearInterval(timerVar[connNum]);
    timerVar[connNum] = 0;
    var connectButton = document.getElementById("Connect" + connNum);
    connectButton.innerHTML = "&nbspConnect&nbsp";
    var baseUrl, title;
    $("#mylistgroup li").each(function(){
        var connNumIter = $(this).attr('connNum');
            if (connNumIter == connNum) {
                baseUrl = $(this).attr('BaseUrl');
                title = $(this).attr('Name');
                g_active_connName = "";
                AddCollapseData("Disconnected", baseUrl, connNum, title, "");
                return;
            }
    });
}

function startVpn(el) {
	var ConnectionName = $(el).parent().parent().attr("Name");
	var baseUrl = $(el).parent().parent().attr("BaseUrl");
    var connNum =  $(el).parent().parent().attr('connNum');
    var connectButton = document.getElementById("Connect" + connNum).innerHTML;
    var message;
    
    if (g_active_connName != "" && g_active_connName != ConnectionName) {
        customAlert(g_active_connName + " is already connected");
    } else {
        if (baseUrl && baseUrl != "https://") { 
            var message = {};
            if (connectButton == "Disconnect") {
                message['command'] = "Disconnect";
                message['connNum'] = connNum;
            } else {
                var connectButton = document.getElementById("Connect" + connNum);
                connectButton.innerHTML = "&nbspConnect&nbsp";
                message['command'] = "startVpn";
                message['connName'] = ConnectionName;
                message['baseUrl'] = baseUrl;
                message['connNum'] = connNum;
            }
            if (!timerVar[connNum]) {
                timerVar[connNum] = setInterval(collapseTest, 5000, $(el).parent());
            }
            
            console.log(JSON.stringify(message));
        } else {
            customAlert("BaseUrl is empty");
        }
    }
}

$(".collapse").on("hide.bs.collapse", function(){
    $(".btn").html('<span class="glyphicon glyphicon-collapse-down"></span> Open');
  });
  
$(".collapse").on("show.bs.collapse", function(){
    $(".btn").html('<span class="glyphicon glyphicon-collapse-up"></span> Close');
});
 
$('#AddConnection').click(function () {
    var message = {};
    message['command'] = "AddConnection";
    
    console.log(JSON.stringify(message));
});

$('#DeleteConnection').click(function () {
    var x;
    if (g_active_connName == $('.list-group').find('.active').attr("Name")) {
        customAlert("Please Disconnect before you delete.");
    } else {
        var msg = "Do you want to delete the connection?";
        bootbox.confirm(msg, function(result) {
            if (result == true) {
	            $('.list-group').find('.active').parent().remove()
                console.log("Trying to delete a connection");
                writeConnectionsToStore();
            }
        });
    }
});

$('#EditConnection').click(function () {
    if (g_active_connName == $('.list-group').find('.active').attr("Name")) {
        customAlert("Please Disconnect before you edit.");
    } else {
        el = $('.list-group').find('.active')
        var ConnectionName = $(el).attr("Name");
        var baseUrl = $(el).attr("BaseUrl");
        var connNum =  $(el).attr('connNum');
        var message = {};
        message['command'] = "EditConnection";
        message['connName'] = ConnectionName;
        message['baseUrl'] = baseUrl;
        message['connNum'] = connNum;
        
        console.log(JSON.stringify(message));
        window.baseUrl = baseUrl;
        var url = "config.html?ConnectionName="+ConnectionName+"&baseUrl="+baseUrl+"&connNum="+connNum;
        var myWin = open(url);
    }
});

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
/*$('#configButtonOk').click(function () {
    var $name = $(document.configForm.inputName1);
    var $url = $(document.configForm.inputUrl1);

    var $data = { 'name': $name.val(), 'url': $url.val()};
    //customAlert("test alert");
    //console.log($data.val());
    console.log("ConfigOK:" + $url.val() + ":" + $name.val());
});*/

$('#configButtonCancel').click(function () {
    var message = {};
    message['command'] = "ConfigCancel";
    
    console.log(JSON.stringify(message));
});

$('#AboutButton').click(function () {
    window.open("about.html")
});

$('#AdvancedStatus').click(function () {
    var connName = $('.list-group').find('.active').attr("Name");
    window.open("advancedConnDetails.html?ConnectionName="+connName);
});

$('#Refresh').click(function () {
    connNameBox = document.getElementById("connNameBox");
    var message = {};
    message['command'] = "FetchAdvConnDetails";
    message['connName'] = connNameBox.connName;
    
    console.log(JSON.stringify(message));
});

$('#DetailedLog').click(function () {
    var message = {};
    message['command'] = "SetDetailedLogging";
    
    console.log(JSON.stringify(message));
});

$('#NormalLog').click(function () {
    var message = {};
    message['command'] = "SetNormalLogging";
    
    console.log(JSON.stringify(message));
});

$('#UploadLogs').click(function () {
    var message = {};
    message['command'] = "UploadLogs";
    
    console.log(JSON.stringify(message));
});

$( document ).ready(function() {
  // Handler for .ready() called.
    htmlName = location.pathname.substring(location.pathname.lastIndexOf("/") + 1);
    if (htmlName == "pulseUi.html") {
        var message = {};
        message['command'] = "FetchConnectionsFromStore";
        
        console.log(JSON.stringify(message));
    }
    if (htmlName == "config.html") {
        var connName = getParameterByName('ConnectionName');
        var baseUrl = getParameterByName('baseUrl');
        var connNum = getParameterByName("connNum");
        var connNameId = document.getElementById("inputName1");
        var baseUrlId = document.getElementById("inputUrl1");
        connNameId.value = connName;
        baseUrlId.value = baseUrl;
        g_edit_connNum = connNum;
    }
    if (htmlName == "advancedConnDetails.html") {
        var connName = getParameterByName('ConnectionName');
        var message = {};
        message['command'] = "FetchAdvConnDetails";
        message['connName'] = connName;
        
        console.log(JSON.stringify(message));
    }
});

function setAdvancedConnDetails(isActiveConnection, connName, bytes_rx, bytes_tx, encr_type, compr_type, nc_mode, tunnelIpAddr, sessionRemainingTime)
{
    connNameBox = document.getElementById("connNameBox");
    connNameBox.innerHTML = "<h5><b>Advanced details:</b> "+connName+"</h5>";
    connNameBox.connName = connName;
    advDetailsBox = document.getElementById("advancedConnDetails");
    if (!isActiveConnection) {
        advDetailsBox.innerHTML = "<br><br><br><br><br><p align='justify' style='margin-left:4em;'> This session is not connected. </p>"
    } else {
        var hrs, mins, secs;
        if (sessionRemainingTime > 0) {
            secs = sessionRemainingTime%60;
            mins = parseInt((sessionRemainingTime/60)%60);
            hrs = parseInt(sessionRemainingTime/3600);
        } else {
            hrs = 0;
            mins = 0;
            secs = 0;
        }
        var SessionTimeRemainingStr = "";
        if (hrs > 0) {
            SessionTimeRemainingStr = hrs+"h ";
        }
        if (mins > 0) {
            SessionTimeRemainingStr += mins+"m ";
        }
        SessionTimeRemainingStr += secs+"s";
        advDetailsBox.innerHTML = "\
                                    <table class='table'>\
                                    <tr> <th> Tunnel IP</th><td>"+tunnelIpAddr+"<td></tr>\
                                    <tr> <th> Bytes Transmitted</th><td>"+bytes_tx+"<td></tr>\
                                    <tr> <th> Bytes Received</th><td>"+bytes_rx+"<td></tr>\
                                    <tr> <th> Encryption Type</th><td>"+encr_type+"<td></tr>\
                                    <tr> <th> Compression Type</th><td>"+compr_type+"<td></tr>\
                                    <tr> <th> Mode</th><td>"+nc_mode+"<td></tr>\
                                    <tr> <th> Session Time Remaining</th><td>"+SessionTimeRemainingStr+"<td></tr>\
                                    </table>"
    }
}

function customAlert(msg)
{
    bootbox.alert(msg);
}

function customConfirm(msg)
{
    var retVal;
    retVal = bootbox.confirm(msg);
    return retVal;
}

