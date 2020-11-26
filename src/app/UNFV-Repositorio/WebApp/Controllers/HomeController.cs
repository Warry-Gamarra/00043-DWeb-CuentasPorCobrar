using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    public class HomeController : Controller
    {
        IAlumnoService _alumnoService;
        IProgramaUnfvService _programaUnfvService;

        public HomeController(
            IAlumnoService alumnoService, 
            IProgramaUnfvService programaUnfvService)
        {
            _alumnoService = alumnoService;
            _programaUnfvService = programaUnfvService;
        }

        public ActionResult Index()
        {
            var example = _alumnoService.GetAll();

            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}