<%@ WebHandler Language="C#" Class="UsernameAvailability" %>

using System;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using Ektron.Cms.Framework.User;
using Ektron.Cms.User;
using Ektron.Cms.Common;
using System.Collections.Generic;

public class UsernameAvailability : IHttpHandler {

    private UserManager _userCRUD = null;
    private UserManager UserCRUD { get { return _userCRUD ?? (_userCRUD = new UserManager(Ektron.Cms.Framework.ApiAccessMode.Admin)); } }

    private JavaScriptSerializer _jser = null;
    private JavaScriptSerializer JSer { get { return _jser ?? (_jser = new JavaScriptSerializer()); } }

    private string[] suggestedSuffixes = { "TheWizard", "Gamgee", "TheWise", "WonderKid", "42", "AndHisMightySteed", "WarriorPrincess", "TheBold", "TheDragon", "OfTheLake", "TheFurious", "ThePeaceful", "3.14", "SpaceCowboy", "SpaceCowgirl", "QueenOfScots" };
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";

        string requestedUsername = context.Request["u"];
        var returnValue = new UserNameResults();

        if (string.IsNullOrEmpty(requestedUsername))
        {
            returnValue.nameIsAvailable = true;
        }
        else 
        {
            var names = GetAvailableNames(requestedUsername);
            if (names.Contains(requestedUsername))
            {
                returnValue.nameIsAvailable = true;
            }
            else
            {
                returnValue.nameIsAvailable = false;
                returnValue.suggestedNames = names.Shuffle().Take(5).ToList();
            }
        }

        context.Response.Write(JSer.Serialize(returnValue));
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

    private List<string> GetNameOptions(string baseName)
    {
        List<string> nameOptions = new List<string>();
        nameOptions.Add(baseName);
        foreach (var suffix in suggestedSuffixes)
        {
            nameOptions.Add(baseName + suffix);
        }
        return nameOptions;
    }
    
    private List<string> GetUsedNames(List<string> nameOptions)
    {
        var criteria = new UserCriteria();
        criteria.AddFilter(UserProperty.UserName, CriteriaFilterOperator.In, nameOptions);
        criteria.AddFilter(UserProperty.IsDeleted, CriteriaFilterOperator.EqualTo, false);
        criteria.PagingInfo = new Ektron.Cms.PagingInfo(nameOptions.Count);
        criteria.ReturnCustomProperties = false;

        criteria.Condition = LogicalOperation.And;
        var userList = UserCRUD.GetList(criteria);

        criteria = new UserCriteria();
        criteria.AddFilter(UserProperty.UserName, Ektron.Cms.Common.CriteriaFilterOperator.In, nameOptions);
        criteria.AddFilter(UserProperty.IsActivated, Ektron.Cms.Common.CriteriaFilterOperator.EqualTo, false);
        criteria.AddFilter(UserProperty.IsMemberShip, Ektron.Cms.Common.CriteriaFilterOperator.EqualTo, true);
        criteria.PagingInfo = new Ektron.Cms.PagingInfo(nameOptions.Count);
        criteria.ReturnCustomProperties = false;
        criteria.Condition = Ektron.Cms.Common.LogicalOperation.And;

        var unverifiedUsers = UserCRUD.GetList(criteria);
        userList.AddRange(unverifiedUsers);

        var usedNameList = userList.Select(u => u.Username);
        return usedNameList.Distinct().ToList();
    }
    
    private List<string> GetAvailableNames(string baseName)
    {
        var nameOptions = GetNameOptions(baseName);
        var usedNames = GetUsedNames(nameOptions);

        return nameOptions.Except(usedNames).ToList();
    }
}

public class UserNameResults
{
    public bool nameIsAvailable { get; set; }
    public List<string> suggestedNames { get; set; }
}

public static class UserNameExtensions
{
    public static IList<T> Shuffle<T>(this IList<T> list)
    {
        var r = new Random();
        int n = list.Count;
        while (n > 1)
        {
            n--;
            int k = r.Next(n + 1);
            T value = list[k];
            list[k] = list[n];
            list[n] = value;
        }
        return list;
    }
}