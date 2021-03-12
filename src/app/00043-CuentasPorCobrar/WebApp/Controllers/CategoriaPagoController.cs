using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class CategoriaPagoController : Controller
    {
        private readonly CategoriaPagoModel _categoriaPago;
        private readonly ConceptoPagoModel _conceptoPago;
        private readonly CuentaDepositoModel _cuentasDeposito;

        public CategoriaPagoController()
        {
            _categoriaPago = new CategoriaPagoModel();
            _conceptoPago = new ConceptoPagoModel();
            _cuentasDeposito = new CuentaDepositoModel();
        }

        [Route("mantenimiento/categorias-de-pago")]
        public ActionResult Index()
        {
            ViewBag.Title = "Categorías de Pago";
            var model = _categoriaPago.Find();
            return View(model);
        }


        [Route("mantenimiento/categorias-de-pago/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo categoría de pago";

            ViewBag.Niveles = new SelectList(_conceptoPago.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado), "Value", "TextDisplay");
            ViewBag.TiposAlumno = new SelectList(_conceptoPago.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno), "Value", "TextDisplay");
            ViewBag.CtasDeposito = new SelectList(_cuentasDeposito.Find(), "Id", "DescripcionFull", "EntidadFinanciera", null, null);

            return PartialView("_RegistrarCategoria", new CategoriaPagoRegistroViewModel()
            {
                CtasBcoComercio = _cuentasDeposito.Find().Where(x => x.EntidadFinancieraId == Constantes.BANCO_COMERCIO_ID).Select(x => x.Id.Value).ToArray()
            });
        }

        [Route("mantenimiento/categorias-de-pago/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar categoría de pago";

            var model = _categoriaPago.Find(id);
            ViewBag.Niveles = new SelectList(_conceptoPago.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado), "Value", "TextDisplay");
            ViewBag.TiposAlumno = new SelectList(_conceptoPago.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno), "Value", "TextDisplay");
            ViewBag.CtasDeposito = new SelectList(_cuentasDeposito.Find(), "Id", "DescripcionFull", "EntidadFinanciera", model.CuentasDeposito, null);

            return PartialView("_RegistrarCategoria", model);
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _categoriaPago.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EntidadFinanciera"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(CategoriaPagoRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _categoriaPago.Save(model, WebSecurity.CurrentUserId);
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

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos. " + details);
            }
            return PartialView("_MsgPartialWR", result);
        }

    }
}