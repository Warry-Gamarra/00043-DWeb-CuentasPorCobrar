using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    [Route("ayuda/{action}")]
    public class HelpCenterController : Controller
    {
        // GET: HelpCenter
        public ActionResult Index()
        {
            //return View();
            return RedirectToAction("Manual", "HelpCenter");
        }

        [Route("ayuda/manuales")]
        public ActionResult Manual()
        {
            ViewBag.Title = "Manual de usuario";
            return View();
        }

        //[Route("ayuda/preguntas-frecuentes")]
        //public ActionResult FAQs()
        //{
        //    ViewBag.Title = "Preguntas frecuentes";
        //    return View();
        //}

        //[Route("ayuda/contactos")]
        //public ActionResult Contacts()
        //{
        //    ViewBag.Title = "Contactos";
        //    return View();
        //}
    }
}