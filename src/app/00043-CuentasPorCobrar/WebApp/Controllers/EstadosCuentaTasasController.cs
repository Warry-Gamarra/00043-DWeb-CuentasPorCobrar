using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    [Authorize]
    [Authorize(Roles = "Administrador, Consulta")]
    public class EstadosCuentaTasasController : Controller
    {
        ITasaServiceFacade tasaService;
        SelectModel selectModels;

        public EstadosCuentaTasasController()
        {
            tasaService = new TasaServiceFacade();
            selectModels = new SelectModel();
        }
        

        [Route("consulta/tasas")]
        public ActionResult Consulta(ConsultaPagoTasasViewModel model)
        {
            ViewBag.Title = "Consulta de Pago de Tasas";

            if (model.buscar)
            {
                model.resultado = tasaService.listarPagoTasas(model.entidadFinanciera, model.codOperacion, model.fechaInicio, model.fechaFin);
            }

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.entidadFinanciera);

            return View(model);
        }
    }
}