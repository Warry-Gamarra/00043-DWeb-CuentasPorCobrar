using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebMatrix.WebData;

namespace WebApp.Controllers
{


    public class EstudiantesController : Controller
    {
        private readonly SeleccionarArchivoModel _seleccionarArchivoModel;

        public EstudiantesController()
        {
            _seleccionarArchivoModel = new SeleccionarArchivoModel();
        }

        [Route("operaciones/cargar-estudiantes-aptos")]
        public ActionResult Index()
        {
            ViewBag.Title = "Cargar Alumnos Aptos";

            return View();
        }


        public ActionResult CargarArchivoPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado);
            return PartialView("_SeleccionarArchivo", model);
        }


        public ActionResult CargarArchivoPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado);
            return PartialView("_SeleccionarArchivo", model);
        }


        [HttpPost]
        public ActionResult CargarArchivoPregrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult CargarArchivoPosgrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


    }
}