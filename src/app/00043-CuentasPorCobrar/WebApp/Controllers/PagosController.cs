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
        private readonly SelectModels selectModels;

        public PagosController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
            selectModels = new SelectModels();
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

        [Route("operaciones/cargar-pagos/obligaciones")]
        public ActionResult ImportarPagoObligaciones()
        {
            ViewBag.Title = "Cargar pagos de obligaciones";
            return View();
        }

        [Route("operaciones/cargar-pagos/tasas")]
        public ActionResult ImportarPagoTasas()
        {
            ViewBag.Title = "Cargar pagos de tasas";
            return View();
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
            //var listaEntidades =  new List<SelectViewModel>();

            //listaEntidades.Add(new SelectViewModel() { Value = "1", TextDisplay = "BANCO DE COMERCIO" });

            //listaEntidades.Add(new SelectViewModel() { Value = "2", TextDisplay = "BANCO DE CRÉDITO" });

            return selectModels.GetEntidadesFinancieras();
        }

        [Route("operaciones/cargar-pagos/seleccionar-archivo/{tipo}")]
        public ActionResult SeleccionarArchivo(string tipo)
        {
            ViewBag.Tipo = $"({tipo.ToUpper()})";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            //var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo");
        }

        [HttpPost]
        public ActionResult CargarArchivoPago(HttpPostedFileBase file, CargarArchivoViewModel model)
        {
            return View();
        }
    }
}