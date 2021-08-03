
declare @VisitStartDate datetime = '2014-01-01'
declare @VisitEndDate datetime = getdate()

if object_id('MSS_U_INFODEL_S.VISITS_BASE_TABLE', 'U') is not null
drop table #VISITS_BASE_TABLE

/* Extract saleforce meetings with attendee information */
create table MSS_U_INFODEL_S.VISITS_BASE_TABLE
with (heap, distribution = hash(VisitID)) as
select	
        a.ID									as VisitID
        ,a.CREATEDDATE							as CreatedDate
        ,a.CREATOR_ROLE__C						as CreatorRole
        ,a.CREATEDBYID							as CreatedByID			-- Creator of visit record
        ,a.START_DATE_TIME__C					as StartDateTime
        ,a.END_DATE_TIME__C						as EndDateTime	
        ,a.DURATION__C							as Duration				-- Visit duration in minutes 
        ,a.VISIT_ATTENDEES__C					as VisitAttendees		-- Number of visit attendees
        ,a.VISIT_TYPE__C						as VisitType
        ,a.NOTES__C								as Notes
        ,a.STATUS__C							as Status
        ,a.CAPTURED_FEEDBACK_VIA__C				as CapturedFeedbackVia	-- How visit feedback was captured: Voice, Text, etc.
        ,a.MARKETING_EVENT__C					as MarketingEventID
        ,a.MARKETING_EVENT_ATTENDEES__C			as MarketingEventAttendees
        ,a.NAME									as Name					-- Visit description
        ,a.ALL_OWNER_INITIALS__C				as AllOwnerInitials		-- List of owners for the visit
        ,a.OWNER_INITIALS__C					as OwnerInitials		-- Primary visit owner initials
        ,a.OWNER_TITLE__C						as OwnerTitle			-- Primary visit owner title
        ,a.FEEDBACK__C							as Feedback
        ,a.PRIMARY_CONTACT__C					as PrimaryContact
        ,a.FOCUS__C	 							as Focus				-- Focus code for a visit part of a Marketing 'Focus' campaign
        ,a.NUM_OF_ATTENDEES__C					as NumOfAttendees 
		,a.MEETING_STATUS__C					as MeetingStatus 
		,a.TIMETRADE_MEETING__C					as TimeTradeMeeting 
		,a.TIMETRADE_MEETING_INVITATION__C		as TimeTradeMeetingInvitation
		,a.VIRTUAL__C							as Virtual
		,b.STATUS__C 							as AttendeeStatus	
        ,b.NOTES__C 							as AttendeeNotes
        ,b.CONTACT__C							as AttendeeContactID
	
from
	MSS_S_SFDC_S.vw_sfdc_visit__c_current a

left join
	MSS_S_SFDC_S.vw_sfdc_attendee__c_current b
on 
    a.ID = b.VISIT__C			

where
	a.NUM_OF_ATTENDEES__C >= 0
	and a.ALL_OWNER_INITIALS__C is not null
	and a.STATUS__C in (select Value from MSS_U_INFODEL_S.SourceValueLookup where ID = 'DoneInProgressVisit')
	and a.START_DATE_TIME__C between @VisitStartDate and @VisitEndDate
