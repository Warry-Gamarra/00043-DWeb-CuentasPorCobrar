using DocumentFormat.OpenXml.EMMA;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
    public class ProcesosController : Controller
    {
        private readonly ProcesoModel _procesoModel;
        private readonly int? _dependenciaUsuarioId;
        private readonly SelectModel _selectModel;
        private readonly ConceptoPagoModel _conceptoModel;
        private readonly CategoriaPagoModel _categoriaPagoModel;
        private readonly CuentaDepositoModel _cuentasDeposito;
        

        public ProcesosController()
        {
            _procesoModel = new ProcesoModel();
            _selectModel = new SelectModel();
            _conceptoModel = new ConceptoPagoModel();
            _categoriaPagoModel = new CategoriaPagoModel();
            _cuentasDeposito = new CuentaDepositoModel();
            
            if (WebSecurity.IsAuthenticated)
            {
                _dependenciaUsuarioId = new UsersModel().Find(WebSecurity.CurrentUserId).DependenciaId;
            }
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos")]
        public ActionResult Obligaciones(int? anio, int? grado)
        {
            ViewBag.Title = "Cuotas de pago y conceptos";

            anio = anio ?? DateTime.Now.Year;
            grado = grado ?? 4;

            ViewBag.Anios = new SelectList(_selectModel.GetAnios(1990), "Value", "TextDisplay", anio);
            ViewBag.AnioSelect = anio;

            ViewBag.Message = TempData["Message"];

            return View("Obligaciones", _procesoModel.Listar_Procesos(anio.Value));
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos/{anio}/nueva-cuota-pago")]
        public ActionResult CreateCuotaPago(int anio)
        {
            ViewBag.Title = "Nueva Cuota de Pago";

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find().Where(x=>x.Habilitado), "Id", "Nombre");
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay", null);
            ViewBag.CtasDeposito = new SelectList(new List<SelectViewModel>());
            ViewBag.MostrarOpcionEdicionObl = false;

            return PartialView("_RegistrarProcesoObligacion", new RegistroProcesoViewModel()
            {
                Anio = anio,
                CtasBcoComercio = _cuentasDeposito.Find().Where(x => x.EntidadFinancieraId == Bancos.BANCO_COMERCIO_ID).Select(x => x.Id.Value).ToArray()
            });
        }


        [Route("configuracion/cuotas-de-pago-y-conceptos/{id}/editar")]
        public ActionResult EditCuotaPago(int id)
        {
            ViewBag.Title = "Editar Cuota de Pago";

            RegistroProcesoViewModel model = _procesoModel.Obtener_Proceso(id);

            var ctasCategoria = new List<SelectViewModel>();

            foreach (var item in _procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.CategoriaId.Value).Select(x => x.ItemsGroup))
            {
                ctasCategoria.AddRange(item);
            }

            var listaCategoriaPago = _categoriaPagoModel.Find();

            ViewBag.Categorias = new SelectList(listaCategoriaPago.Where(x => x.Id == model.CategoriaId.Value), "Id", "Nombre");
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo().Where(x => x.Value == model.PerAcadId.ToString()), "Value", "TextDisplay", model.PerAcadId);
            ViewBag.CtasDeposito = new SelectList(ctasCategoria, "Value", "TextDisplay", "NameGroup", model.CtaDepositoID, null);

            if (!model.MostrarCodBanco && String.IsNullOrEmpty(model.CodBcoComercio))
            {
                ViewBag.CodBcoComercio = listaCategoriaPago.First(x => x.Id == model.CategoriaId.Value).CodBcoComercio;
            }

            ViewBag.MostrarOpcionEdicionObl = (model.PrioridadId == 1);

            return PartialView("_RegistrarProcesoObligacion", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistroProcesoViewModel model, DateTime txtFecVencto)
        {
            Response result = new Response();

            model.FecVencto = txtFecVencto;

            if (ModelState.IsValid)
            {
                result = _procesoModel.Grabar_Proceso(model, WebSecurity.CurrentUserId);
            }
            else
            {
                string details = "";

                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);
            }

            return PartialView("_MsgPartialWR", result);
        }


        [Route("configuracion/cuotas-de-pago-y-conceptos/{procesoId}/conceptos-de-pago")]
        public ActionResult VerConceptos(int procesoId)
        {
            ViewBag.Title = _procesoModel.Obtener_Proceso(procesoId).DescProceso;
            ViewBag.ProcesoId = procesoId;

            var model = _procesoModel.ObtenerConceptosProceso(procesoId);

            return PartialView("_ListadoConceptosProceso", model);
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos/{id}/obtener-fecha-vencimiento")]
        public ActionResult EditFechaVencPension(int id)
        {
            ViewBag.Title = "Actualizar fecha de vencimiento";

            ViewBag.ProcesoID = id;

            var model = _procesoModel.Listar_FechaVencimientoObligacion(id);

            return PartialView("_EditFechaVencPension", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HandleJsonExceptionAttribute]
        public ActionResult SaveFechaVencimiento(string newFechaVcto, string oldFechaVcto, int idProceso)
        {
            Response response;

            DateTime newFechVcto = DateTime.ParseExact(newFechaVcto, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);

            DateTime oldFechVcto = DateTime.ParseExact(oldFechaVcto, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);

            response = _procesoModel.Actualizar_FechaVctoObligacion(newFechVcto, oldFechVcto, idProceso, WebSecurity.CurrentUserId);


            return Json(response, JsonRequestBehavior.AllowGet);
        }
    }
}