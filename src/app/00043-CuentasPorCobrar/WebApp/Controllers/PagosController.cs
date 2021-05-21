using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;
using Domain.Helpers;
using WebApp.Models;
using System.Globalization;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class PagosController : Controller
    {
        private readonly IGeneralServiceFacade generalServiceFacade;
        private readonly ICatalogoServiceFacade catalogoServiceFacade;
        private readonly IObligacionServiceFacade obligacionServiceFacade;
        private readonly IAlumnosClientFacade alumnosClientFacade;
        private readonly IProgramasClientFacade programasClientFacade;
        private readonly SelectModel selectModels;
        private readonly PagosModel pagosModel;

        public PagosController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
            selectModels = new SelectModel();
            pagosModel = new PagosModel();
        }

        // GET: Pagos
        public ActionResult Index()
        {
            ViewBag.Title = "Pagos Registrados";
            return View();
        }


        [Route("operaciones/generar-archivos-pago")]
        public ActionResult ExportarDatosPago()
        {
            ViewBag.Title = "Generar archivos de pago";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            ViewBag.EntidadesFinancieras = new List<SelectViewModel>();

            var model = new FiltroEnvioObligacionesModel()
            {
                I_Anio = DateTime.Now.Year,
                I_Periodo = 15,
                E_TipoEstudio = TipoEstudio.Pregrado,
                T_Facultad = "",
                T_FechaDesde = DateTime.Now.ToString("dd/MM/yyyy")
            };

            return View(model);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("operaciones/generar-archivos-pago")]
        public ActionResult GenerarArchivosBancos(FiltroEnvioObligacionesModel model)
        {
            try
            {
                var transferenciaInformacion = TransferenciaInformacionFactory.Get(model.I_EntidadFinanciera);

                var memoryStream = transferenciaInformacion.GenerarInformacionObligaciones(model.I_Anio, model.I_Periodo, model.E_TipoEstudio, model.T_Facultad, model.D_FechaDesde, model.D_FechaHasta);

                return File(memoryStream, "text/plain", transferenciaInformacion.NombreArchivoGenerado());
            }
            catch (Exception ex)
            {
                ViewBag.Title = "Generar archivos de pago";

                ViewBag.Anios = generalServiceFacade.Listar_Anios();

                ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

                ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

                ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

                ViewBag.EntidadesFinancieras = new List<SelectViewModel>();

                ModelState.AddModelError("", ex.Message);

                return View("ExportarDatosPago", model);
            }
        }

        [Route("operaciones/cargar-pagos")]
        public ActionResult ImportarArchivosPago()
        {
            ViewBag.Title = "Cargar Pagos";
            return View();
        }

        private IEnumerable<SelectViewModel> ListaEntidadesFinancieras()
        {
            return selectModels.GetEntidadesFinancieras();
        }


        //[Route("operaciones/cargar-pagos/obligaciones")]
        public ActionResult ImportarPagoObligaciones()
        {
            ViewBag.Title = "Cargar pagos de obligaciones";
            var model = new List<ArchivoImportadoViewModel>();
            return View(model);
        }

        [Route("operaciones/cargar-pagos/seleccionar-archivo/obligaciones")]
        public ActionResult SeleccionarArchivoObligaciones()
        {
            ViewBag.Tipo = "(OBLIGACIONES)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");

            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Obligacion};

            return PartialView("_SeleccionarArchivo", model);
        }

        //[Route("operaciones/cargar-pagos/tasas")]
        public ActionResult ImportarPagoTasas()
        {
            ViewBag.Title = "Cargar pagos de tasas";
            var model = new List<ArchivoImportadoViewModel>();
            return View(model);
        }


        [Route("operaciones/cargar-pagos/seleccionar-archivo/tasas")]
        public ActionResult SeleccionarArchivoTasas()
        {
            ViewBag.Tipo = "(TASAS)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");

            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Tasa }; ;
            return PartialView("_SeleccionarArchivo", model);
        }


        [HttpPost]
        public ActionResult CargarArchivoPago(HttpPostedFileBase file, CargarArchivoViewModel model)
        {
            var result = pagosModel.CargarArchivoPagos(Server.MapPath("~/Upload/Pagos/"), file, model, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        //[Route("operaciones/cargar-pagos/registro-manual")]
        public ActionResult RegistrarObligacionManual()
        {
            
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");
            ViewBag.Especialidades = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");
            ViewBag.Proceso = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            
            var model = new ObligacionManualViewModel();

            return PartialView("_RegistrarObligacion", model);
        }

        [HttpPost]
        public ActionResult RegistrarObligacionManual(ObligacionManualViewModel model)
        {
            Object result = null;

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        //[Route("operaciones/cargar-pagos/registro-manual")]
        public ActionResult RegistrarTasaManual()
        {
            ViewBag.Tasas = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");

            var model = new TasaManualViewModel();

            return PartialView("_RegistrarTasa", model);
        }
    }
}
