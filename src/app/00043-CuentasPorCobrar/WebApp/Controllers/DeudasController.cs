using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    [Authorize]
    public class DeudasController : Controller
    {
        // GET: Deudas
        [Route("consultas/deudas-registradas")]
        public ActionResult Index()
        {
            ViewBag.Title = "Deudas registradas";
            return View();
        }
    }
}