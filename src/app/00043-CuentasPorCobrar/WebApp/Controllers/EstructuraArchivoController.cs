using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    public class EstructuraArchivoController : Controller
    {
        private readonly EntidadFinanciera _entidadFinanciera;

        public EstructuraArchivoController()
        {
            _entidadFinanciera = new EntidadFinanciera();
        }

        // GET: EstructuraArchivo
        [Route("configuracion/estructura-archivos")]
        public ActionResult Index()
        {
            ViewBag.Title = "Estructura de archivos";

            return View();
        }


        [Route("configuracion/entidad-financiera/{id}/estructura-archivos")]
        public ActionResult Banco(int Id)
        {
            ViewBag.Title = "Estructura de archivos: " + _entidadFinanciera.Find(Id).Nombre.ToUpper();

            return View();
        }

    }
}