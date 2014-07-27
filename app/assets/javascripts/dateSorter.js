/*
 * Author: rabisg
 * Adapted from https://github.com/DataTables/Plugins/blob/master/sorting/date-dd-MMM-yyyy.js
 */

/*
 * Adds a new sorting option to dataTables called `date-dd-mmm-yyyy`. Also
 * includes a type detection plug-in. Matches and sorts date strings in
 * the format: `dd/mmm/yyyy`. For example:
 *
 * * 02-FEB-1978
 * * 17-MAY-2013
 * * 31-JAN-2014
 *
 *  @name Date (dd-mmm-yy)
 *  @summary Sort dates in the format `dd-mmm-yyyy`
 *  @author [Jeromy French](http://www.appliedinter.net/jeromy_works/)
 *
 *  @example
 *    $('#example').dataTable( {
 *       columnDefs: [
 *         { type: 'date-dd-mmm-yyyy', targets: 0 }
 *       ]
 *    } );
 */

(function () {

    var customDateDDMMMYYToOrd = function (date) {
	"use strict";
	// Convert to a number YYMMDD which we can use to order
	if(date.trim() == "Not Contacted")
	    return 0;
	var dateParts = date.split(/ |\n/);
	var val = (dateParts[2] * 10000) + ($.inArray(dateParts[1].toUpperCase(), ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]) * 100) + (dateParts[0]*1);
	return val;
    };

    // This will help DataTables magic detect the "dd-MMM-yyyy" format; Unshift
    // so that it's the first data type (so it takes priority over existing)
    jQuery.fn.dataTableExt.aTypes.unshift(
	function (sData) {
	    "use strict";
	    if (/^([0-2]?\d|3[0-1]) (jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec) \d{2}/i.test(sData) ||
		sData.trim() == "Not Contacted") {
		return 'date-dd-mmm-yy';
	    }
	    return null;
	}
    );

    // define the sorts
    jQuery.fn.dataTableExt.oSort['date-dd-mmm-yy-asc'] = function (a, b) {
	"use strict";
	var ordA = customDateDDMMMYYToOrd(a),
	ordB = customDateDDMMMYYToOrd(b);
	return (ordA < ordB) ? -1 : ((ordA > ordB) ? 1 : 0);
    };

    jQuery.fn.dataTableExt.oSort['date-dd-mmm-yy-desc'] = function (a, b) {
	"use strict";
	var ordA = customDateDDMMMYYToOrd(a),
	ordB = customDateDDMMMYYToOrd(b);
	return (ordA < ordB) ? 1 : ((ordA > ordB) ? -1 : 0);
    };

})();
