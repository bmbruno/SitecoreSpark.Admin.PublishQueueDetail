<!--

	Sitecore Admin: Publish Queue Detail
	by Brandon Bruno (www.brandonbruno.com)
	
	ABOUT
	Use this drop-in admin utility to view items in the Sitecore Publish Queue.

	INSTRUCTIONS
	Drop this ASPX file into your Sitecore Admin directory (<your_website_root>/sitecore/admin) and browse to it.
	Be patient, it make take 60-90 seconds to load on first run.

	CONTACT
	Questions, comments, issues? Visit the repo: https://github.com/bmbruno/SitecoreSpark.Admin.PublishQueueDetail

	VERSION
	1.0.1

-->

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Sitecore.Publishing" %>
<%@ Import Namespace="Sitecore.Publishing.Pipelines.Publish" %>
<%@ Import Namespace="Sitecore.Globalization" %>
<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="Sitecore.Workflows" %>
<%@ Page Language="C#" %>

<script runat="server">

	public void Page_Load(object sender, EventArgs e)
	{	
		// Update these values to match your databases
		const string dbMaster = "master";
		const string dbWeb = "web";
		
		Database masterDB = Database.GetDatabase(dbMaster);
		Database webDB = Database.GetDatabase(dbWeb);
		List<PublishQueueItem> model = new List<PublishQueueItem>();

		// Note on language: the actual publish pipeline uses the language parameter; it doesn't matter what we pass in for this usage
		PublishOptions options = new PublishOptions(masterDB, webDB, PublishMode.Incremental, Language.Parse("en"), DateTime.Now.AddDays(1));
		IEnumerable<PublishingCandidate> candidateList = PublishQueue.GetPublishQueue(options);

		if (candidateList != null && candidateList.Count() > 0)
		{
			foreach (PublishingCandidate candidate in candidateList)
			{
				// Get detailed item information (including workflow info for inclusion/exclusion on report)
				Item scItem = masterDB.GetItem(itemId: candidate.ItemId);

				// If scItem is null, it likely means an item was deleted from 'master' before a publish (and still exists in the PublishQueue table); safe to ignore
				if (scItem == null)
					continue;

				// Check for all language versions (Workflow is shared, but Workflow State may be unique across languages)
				foreach (Language language in scItem.Languages)
				{
					Item scLanguageItem = masterDB.GetItem(itemId: scItem.ID, language: language);

					// Alt language versions do not automatically have a version number, so it's worth a check before proceeding
					if (scLanguageItem.Versions.Count == 0)
						continue;
					
					IWorkflow itemWorkflow = masterDB.WorkflowProvider.GetWorkflow(scLanguageItem);

					if (itemWorkflow == null)
						continue;

					WorkflowState state = itemWorkflow.GetState(scLanguageItem);

					if (state != null && state.FinalState)
					{
						// Map to domain model
						model.Add(new PublishQueueItem()
						{
							ItemID = candidate.ItemId.Guid,
							ItemName = scItem.Name,
							Language = language.Name,
							Action = candidate.PublishAction.ToString(),
							SourceDatabase = candidate.PublishOptions.SourceDatabase.Name,
							TargetDatabase = candidate.PublishOptions.TargetDatabase.Name
						});
					}
				}
			}
		}
		
		litOutput.Text = model.Count.ToString();

		if (model.Count > 0)
		{
			rptReport.DataSource = model;
			rptReport.DataBind();
			rptReport.Visible = true;
		}
		else
		{
			rptReport.Visible = false;
		}
	}

	public class PublishQueueItem
	{
		public Guid ItemID { get; set; }
		public string ItemName { get; set; }
		public string Language { get; set; }
		public string Action { get; set; }
		public string SourceDatabase { get; set; }
		public string TargetDatabase { get; set; }
	}

</script>

<html>

	<head>
		<title>Publish Queue Detail</title>
		
		<script src="/sitecore/shell/controls/InternetExplorer.js" type="text/javascript"></script>
		<script src="/sitecore/shell/controls/Sitecore.js" type="text/javascript"></script>
	</head>
	
	<style>
		body { margin: 1em; background-color: #FFF; text-align: center; font-family: 'Arial', sans-serif; }
		a, a:visited { color: #A00; text-decoration: none; }
		a:hover { color: #F55; text-decoration: underline; } 
		table { margin: 0 auto; border-collapse: collapse; }
		table th, td { padding: 0.5em 1em; }
		table th { background-color: #7C7C7C; color: #EEE; text-shadow: 1px 1px 0px #000; text-align: left; }
		table tr:nth-child(even) { background-color: #EEE; }
		table tr:nth-child(odd) { background-color: #DDD; }
		.about { margin: 1em auto; background-color: #DDD; max-width: 400px; padding: 1em; border-radius: 8px; font-size: 12px; }
	</style>
	
	<body>
	
		<form id="Form1" method="post" runat="server">
		
			<h1>Publish Queue Detail</h1>

			<p>This report displays items in a <strong>final workflow state</strong>. Items without any assigned workflow will not be displayed, but may be published.</p>
			
			<p><a href="/sitecore/admin">Sitecore Admin</a></p>
			
			<p>Items in publish queue: <strong><asp:Literal id="litOutput" runat="server" /></strong></p>
			
			<asp:Repeater id="rptReport" runat="server">
			
				<HeaderTemplate>
					<table>
						<thead>
							<tr>
								<th></th>
								<th>ItemID</th>
								<th>Item Name</th>
								<th>Language</th>
								<th>Action</th>
								<th>Source</th>
								<th>Target</th>
							</tr>
						</thead>
						<tbody>
				</HeaderTemplate>
			
				<ItemTemplate>
					<tr>
						<td style="text-align: right; padding-right: 0;"><a href='/sitecore/shell/sitecore/content/Applications/Content Editor.aspx?id=<%# Eval("ItemID") %>&la=<%# Eval("Language") %>&fo=<%# Eval("ItemID") %>' target="_blank"><img src="/sitecore/shell/Themes/Standard/Images/Editor/LinkManager.gif" alt="Open item in Content Editor." title="Open item in Content Editor." /></a></td>
						<td><span id='itemid_<%# Eval("ItemID") %>' onclick='window.getSelection().selectAllChildren(document.getElementById("itemid_<%# Eval("ItemID") %>"));'><%# Eval("ItemID") %></span></td>
						<td><%# Eval("ItemName") %></td>
						<td><%# Eval("Language") %></td>
						<td><%# Eval("Action") %></td>
						<td><%# Eval("SourceDatabase") %></td>
						<td><%# Eval("TargetDatabase") %></td>
					</tr>
				</ItemTemplate>

				<FooterTemplate>
						</tbody>
					</table>
				</FooterTemplate>
			
			</asp:Repeater>
			
			<div class="about">
				Created by <a href="https://www.brandonbruno.com" target="_blank">Brandon Bruno</a> - <a href="https://github.com/bmbruno/SitecoreSpark.Admin.PublishQueueDetail" target="_blank">GitHub</a> - <a href="https://www.sitecorespark.com" target="_blank">Sitecore Spark</a>
			</div>
		
		</form>
	
	</body>
	
</html>
