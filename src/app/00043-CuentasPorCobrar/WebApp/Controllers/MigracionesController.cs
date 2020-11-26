using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.ViewModels;
using WebApp.Models;
using Domain.Services;
using Domain.Entities;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    public class MigracionesController : Controller
    {
        public readonly IMigracionTablas _migracionTablas;
        public MigracionesController()
        {
            _migracionTablas = new MigracionTablas();
        }

        // GET: Migraciones
        public ActionResult Index()
        {
            ViewBag.Title = "Migracion de tablas";

            return View(new MigracionTablasViewModel());
        }

        public ActionResult SeleccionarArchivo(TablaMigracion id)
        {
            ViewBag.Title = "Seleccionar archivo";
            ViewBag.Tabla = id;

            return PartialView("_SeleccionarArchivo");
        }

        [HttpPost]
        public ActionResult CargarArchivo(HttpPostedFileBase file, TablaMigracion tabla)
        {
            Response result = new Response();
            result = _migracionTablas.GuardarTabla(Server.MapPath("~/Upload/Tablas/"), file, tabla, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }
    }
}