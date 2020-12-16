using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            ViewBag.Title = "Dashboard";

            return View();
        }

        public ActionResult Dashboard()
        {
            ViewBag.Title = "Dashboard";

            return View("Index");
        }

    }
}