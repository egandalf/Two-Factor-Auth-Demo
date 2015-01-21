using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Ektron.Cms;
using Ektron.Cms.Framework.Content;
using Ektron.Cms.Framework.User;
using Ektron.Cms.User;
using Twilio;

public partial class webforms_Login : System.Web.UI.Page
{
    private UserManager _userCRUD = null;
    private UserManager UserCRUD
    {
        get
        {
            if (_userCRUD == null)
                _userCRUD = new UserManager(Ektron.Cms.Framework.ApiAccessMode.Admin);
            return _userCRUD;
        }
    }

    protected override void OnLoad(EventArgs e)
    {
        if (Ektron.Cms.Framework.Context.UserContextService.Current.IsLoggedIn)
        {
            var loggedInUser = UserCRUD.GetItem(Ektron.Cms.Framework.Context.UserContextService.Current.UserId);
            if (loggedInUser != null)
            {
                uxLoggedInUsername.Text = loggedInUser.Username;
                uxLoginBox.SetActiveView(uxLogout);
            }
            else
            {
                uxLoginBox.SetActiveView(uxUserCredentials);
            }
        }
        else
        {
            if (!Page.IsPostBack)
            {
                uxLoginBox.SetActiveView(uxUserCredentials);
            }
        }
    }

    protected void uxRegister_Click(object sender, EventArgs e)
    {
        var username = uxRegUsername.Text;
        var pass = uxRegPassword.Text;
        var fname = uxFirstName.Text;
        var lname = uxLastName.Text;
        var email = uxRegEmail.Text;
        var phone = uxRegPhone.Text;

        var newUser = new UserData();
        newUser.Username = username;
        newUser.DisplayName = username;
        newUser.AuthenticationUserId = username;
        newUser.AuthenticationTypeId = 0;
        newUser.FirstName = fname;
        newUser.LastName = lname;
        newUser.Email = email;
        newUser.Password = pass;
        newUser.IsMemberShip = true;
        newUser.IsDeleted = false;

        var customproperties = UserCRUD.GetCustomPropertyList();
        customproperties["Time Zone"].Value = "Eastern Standard Time";
        customproperties["Mobile Phone"].Value = phone;

        newUser.CustomProperties = customproperties;

        UserCRUD.Add(newUser);

        uxRegSuccess.Visible = true;
    }

    protected void uxLogin_Click(object sender, EventArgs e)
    {
        string u = uxUsername.Text;
        string p = uxPassword.Text;

        var token = UserCRUD.Authenticate(u, p);
        if (!string.IsNullOrEmpty(token))
        {
            var user = GetUserByUsername(u);
            if (user != null)
            {
                int code = GetRandomCode();
                
                SetCodeForUser(user, code);

                SetClearCodeTimeout(user.Id);

                SendCodeToUser(code, user.CustomProperties["Mobile Phone"].Value.ToString());

                var indir = GetIndirectReference(user.Id);
                uxObjectReference.Value = indir.ToString();

                uxLoginBox.SetActiveView(uxDualFactorAuth);
            }
        }
    }

    protected void uxVerify_Click(object sender, EventArgs e)
    {
        string indir_str = uxObjectReference.Value;
        string code_str = uxAuthenticationCode.Text;

        Guid indir = Guid.Parse(indir_str);
        long userId = GetDirectReference(indir);

        var user = UserCRUD.GetItem(userId, true);

        var storedCode = user.CustomProperties["Activation Code"].Value.ToString();
        if (code_str == storedCode)
        {
            UserCRUD.Login(user.AuthenticationTypeId, user.AuthenticationUserId);

            user.CustomProperties["Activation Code"].Value = string.Empty;
            UserCRUD.Update(user);

            Response.Redirect(Request.RawUrl);
        }
    }

    protected void uxLogout_Click(object sender, EventArgs e)
    {
        UserCRUD.Logout();
        Response.Redirect(Request.RawUrl);
    }

    private UserData GetUserByUsername(string username)
    {
        var userCriteria = new UserCriteria();
        userCriteria.AddFilter(UserProperty.UserName, Ektron.Cms.Common.CriteriaFilterOperator.EqualTo, username);
        //userCriteria.AddFilter(UserProperty.AuthenticationTypeId, Ektron.Cms.Common.CriteriaFilterOperator.EqualTo, 0);
        userCriteria.ReturnCustomProperties = true;
        userCriteria.Condition = Ektron.Cms.Common.LogicalOperation.And;
        userCriteria.PagingInfo = new Ektron.Cms.PagingInfo(1, 1);

        var userList = UserCRUD.GetList(userCriteria);
        if (userList.Any())
        {
            return userList.First();
        }
        return null;
    }

    private void SetCodeForUser(UserData user, int code)
    {
        var props = user.CustomProperties;
        props["Activation Code"].Value = code;
        user.CustomProperties = props;

        UserCRUD.Update(user);
    }

    private void SetClearCodeTimeout(long userid)
    {
        var timer = new ClearAuthenticationCodeTimer(30 * 60 * 1000);
        timer.UserID = userid;
        timer.AutoReset = false;
        timer.Elapsed += new System.Timers.ElapsedEventHandler(timer_Elapsed);
        timer.Enabled = true;
    }

    private int GetRandomCode()
    {
        var random = new Random();
        return random.Next(100000, 999999);
    }

    private void SendCodeToUser(int code, string phone)
    {
        var number = System.Configuration.ConfigurationManager.AppSettings["TwilioNumber"];
        var sid = System.Configuration.ConfigurationManager.AppSettings["TwilioSID"];
        var token = System.Configuration.ConfigurationManager.AppSettings["TwilioToken"];

        var t = new TwilioRestClient(sid, token);
        var message = t.SendMessage(number, phone, string.Format("Your sandbox verification code is: {0}", code));
        if (message.ErrorCode.HasValue && !string.IsNullOrEmpty(message.ErrorMessage))
        {
            Ektron.Cms.EkException.LogException(string.Format("Error {0} from Twilio: {1}", message.ErrorCode, message.ErrorMessage));
        }
    }

    private long GetDirectReference(Guid indirectReference)
    {
        var map = (Dictionary<Guid, long>)Session["IndirMap"];
        return map[indirectReference];
    }

    private Guid GetIndirectReference(long directReference)
    {
        var map = (Dictionary<long, Guid>)Session["DirMap"];
        return map == null ? AddDirectReference(directReference) : map[directReference];
    }

    private Guid AddDirectReference(long directReference)
    {
        var indirectReference = Guid.NewGuid();
        Session["DirMap"] = new Dictionary<long, Guid> { { directReference, indirectReference } };
        Session["IndirMap"] = new Dictionary<Guid, long> { { indirectReference, directReference } };
        return indirectReference;
    }

    private void timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
    {
        var myTimer = (ClearAuthenticationCodeTimer)sender;

        var user = UserCRUD.GetItem(myTimer.UserID, true);
        if (user != null)
        {
            user.CustomProperties["Activation Code"].Value = string.Empty;
            UserCRUD.Update(user);
        }

        myTimer.Enabled = false;
        myTimer.Dispose();
    }
}

public class ClearAuthenticationCodeTimer : System.Timers.Timer
{
    public ClearAuthenticationCodeTimer(double interval) : base(interval) 
    { }

    public long UserID { get; set; }
}