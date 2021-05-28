using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class DevolucionController : Controller
    {
        // GET: Devoluciones
        public readonly EntidadRecaudadoraModel _entidadRecaudadora;

        public DevolucionController()
        {
            _entidadRecaudadora = new EntidadRecaudadoraModel();
        }

        [Route("operaciones/devolucion-pagos")]
        public ActionResult Index()
        {
            ViewBag.Title = "Devolución de pagos";
            var model = new List<DevolucionesViewModel>();

            return View(model);
        }

        [Route("operaciones/devolucion-pagos/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nueva devolución de pago";
            ViewBag.EntidadRecaudadora = new SelectList(_entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");

            return PartialView("_RegistrarDevolucionPago", new RegistrarDevolucionPagoViewModel());
        }

    }
}