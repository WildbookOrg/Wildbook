<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=utf-8" language="java" import="org.joda.time.LocalDateTime,
org.joda.time.format.DateTimeFormatter,
org.joda.time.format.ISODateTimeFormat,java.net.*,
java.util.List, java.util.ArrayList,
org.ecocean.grid.*,
org.ecocean.media.MediaAsset,
java.io.*,java.util.*, java.io.FileInputStream, java.io.File, java.io.FileNotFoundException, org.ecocean.*,org.ecocean.servlet.*, org.ecocean.*,org.ecocean.servlet.importer.*, javax.jdo.*, java.lang.StringBuffer, java.util.Vector, java.util.Iterator, java.lang.NumberFormatException"%>

<%!

	boolean relevantEncounter(Encounter enc, Shepherd myShepherd) {
    // return ("BPC_OvrvwWtd_Fldr161_2020_3_24".equals(enc.getOccurrenceID()));
		long cutoff = 1610006400000l; // 1/8/2021, PST
		long submitted = enc.getDWCDateAddedLong();
		boolean rightTime = (submitted < cutoff);
		if (!rightTime) return false;
		// yet even if this is old (ie rightTime=true) we might have since run it through the assigner
		Occurrence occ = myShepherd.getOccurrence(enc);
		if (occ == null) return false;
		Long latestDetection = occ.getLatestDateAddedLong();
		rightTime = latestDetection < cutoff;
		ImportTask tasky = myShepherd.getImportTaskForEncounter(enc);
		boolean hasTask = (tasky!=null);
		boolean noClonesOnOcc = !occ.hasCloneEncounters();
		return (hasTask && rightTime && noClonesOnOcc);
	}

%>


<%

boolean committing=false;
boolean skipMain = false;

String context="context0";
context=ServletUtilities.getContext(request);

Shepherd myShepherd=new Shepherd(context);



%>

<html>
<head>
<title>Fix Standard Children</title>

</head>


<body>

<ul>
<%

myShepherd.beginDBTransaction();

int numFixes=0;
int newAnnotations=0;
int numResetAnnots=0;
int nulledStatuses=0;
int numOrphanAssets=0;
int numDatalessAssets=0;
int numDatasFixed=0;
int numAssetsFixed=0;
int numAssetsWithoutStore=0;
int numTrivialAnns=0;
int numEncs=0;

int nPredetectionMasBefore=0;
int nPredetectionMasAfter=0;
int deletedAnnots=0;

Set<String> badAnnotations = new HashSet<String>();

int count=0;
%><p>Committing = <%=committing%>.</p><%

int stopAfter=100000;
int printPeriod = 1;

Set<String> mediaAssetAcmIds = new TreeSet<String>();
Set<Integer> mediaAssetIds = new TreeSet<Integer>();

// just to test the filters without doing anything else
int grantsEncounters = 0;
int encountersChecked = 0;

%><p>Resetting annotations with stopAfter=<%=stopAfter%></p>
<%
try{

	System.out.println("resetAnnotations about to get allEncs");
	List<Encounter> allEncs=myShepherd.getEncountersByField("genus","Lycaon");
	//List<Encounter> allEncs=myShepherd.getEncountersByField("genus","Eubalaena");
	System.out.println("resetAnnotations just got allEncs");
	numEncs = allEncs.size();

	for (int i=0; i<numEncs && count<stopAfter; i++){
		boolean verbose = ((count % printPeriod) == 0);

		Encounter enc = allEncs.get(i);
		int nTrivialMAsThisEnc = enc.nPredetectionMas();
		int nAnnotsBefore = enc.numAnnotations();
		encountersChecked++;

		if (!relevantEncounter(enc, myShepherd)) continue;

		nPredetectionMasBefore += nTrivialMAsThisEnc;

		count++;
		if (verbose) {
			Occurrence occ = myShepherd.getOccurrence(enc);
			boolean hasClones = occ.hasCloneEncounters();
			%><li><ul>
				<li>Encounter <a href="<%=enc.getWebUrl(request)%>"><%=enc %> </a></li>
				<li>Occurrence <%=occ.getID()%> hasClones = <%=hasClones%></li>
				</ul></li><%
		}

		if (skipMain) continue;

		enc.resetAllAnnotations(myShepherd, committing);
		int nTrivialMAsThisEncAfter = enc.nPredetectionMas();
		nPredetectionMasAfter += nTrivialMAsThisEncAfter;
		int nAnnotsAfter = enc.numAnnotations();
		deletedAnnots += (nAnnotsBefore - nAnnotsAfter);



		if (committing && verbose) {
			myShepherd.updateDBTransaction();
		}

		if (nTrivialMAsThisEncAfter!=nTrivialMAsThisEnc) numFixes++;
	} // end Encounter loop
	if (committing) {
		%><p>Committing now!</p><%
		myShepherd.commitDBTransaction();
		myShepherd.beginDBTransaction();
	}
}
catch(Exception e){
	myShepherd.rollbackDBTransaction();
}
finally{
	myShepherd.closeDBTransaction();

}


%>

</ul>
<p>Done successfully: <%=numEncs %> Encounters</p>
<p>Done successfully: <%=encountersChecked %> encounters checked</p>
<p>Done successfully: <%=count %> of those passed needsToBeFixed</p>
<p>Done successfully: <%=numFixes %> modified Encounters</p>
<p>Done successfully: <%=nPredetectionMasBefore %> Predetection MAs Before</p>
<p>Done successfully: <%=nPredetectionMasAfter %> Predetection MAs After</p>
<p>Done successfully: <%=nPredetectionMasAfter-nPredetectionMasBefore %> nulled MAs</p>
<p>Done successfully: <%=deletedAnnots %> deleted annots</p>
<p>Bad annotations (<%=badAnnotations.size()%>): <ul>
<%
for (String badAnn: badAnnotations) {
	%><li><%=badAnn%></li><%
}
%>
</ul></p>

<br>
<p>Media Asset acmIds (<%=mediaAssetAcmIds.size()%>):</p>
<p><code><%=mediaAssetAcmIds.toString()%></code></p>

<br>
<p>Media Asset ids (<%=mediaAssetIds.size()%>):</p>
<p><code><%=mediaAssetIds.toString()%></code></p>


</body>
</html>
