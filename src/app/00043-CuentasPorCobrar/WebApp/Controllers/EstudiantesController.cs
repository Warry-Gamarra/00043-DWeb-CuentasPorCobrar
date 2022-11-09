using ClosedXML.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONSULTA + ", " + RoleNames.DEPENDENCIA + ", " + RoleNames.TESORERIA)]
    public class EstudiantesController : Controller
    {
        private readonly EstudianteModel _seleccionarArchivoModel;

        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IMatriculaServiceFacade matriculaServiceFacade;

        IReportePregradoServiceFacade reportePregradoServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;

        UsersModel usersModel;

        public EstudiantesController()
        {
            _seleccionarArchivoModel = new EstudianteModel();
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            matriculaServiceFacade = new MatriculaServiceFacade();

            reportePregradoServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();

            usersModel = new UsersModel();
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-estudiantes")]
        public ActionResult Index()
        {
            ViewBag.Title = "Carga de Alumnos";

            return View();
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-aptos-pregrado")]
        public ActionResult CargarArchivoMatriculaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-aptos-posgrado")]
        public ActionResult CargarArchivoMatriculaPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }


        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-multas-pregrado")]
        public ActionResult CargarArchivoMultaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.MultaNoVotar);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult CargarArchivoMatricula(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMatricula(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            var response = Mapper.DataMatriculaResponse_To_Response(result);

            Session["MATRICULA_RESPONSE"] = result.DataMatriculasObs;
            Session["MATRICULA_RESPONSE_TIPO_ALUMNO"] = tipoAlumno;

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [Route("operaciones/cargar-aptos/resultado")]
        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        public ActionResult DescargarRegistrosObservados()
        {
            if (Session["MATRICULA_RESPONSE"] == null || Session["MATRICULA_RESPONSE_TIPO_ALUMNO"] == null)
                return  RedirectToAction("cargar-estudiantes", "operaciones");

            TipoAlumno tipoAlumno = (TipoAlumno)Session["MATRICULA_RESPONSE_TIPO_ALUMNO"];

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Students");
                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Cod_rc";
                worksheet.Cell(currentRow, 2).Value = "Cod_alu";
                worksheet.Cell(currentRow, 3).Value = "Año";
                worksheet.Cell(currentRow, 4).Value = "P";
                worksheet.Cell(currentRow, 5).Value = "Est_mat";
                worksheet.Cell(currentRow, 6).Value = "Nivel";
                worksheet.Cell(currentRow, 7).Value = "Es_ingresa";
                worksheet.Cell(currentRow, 8).Value = "Cred_desap";

                int obsRow = 9;

                if (tipoAlumno.Equals(TipoAlumno.Pregrado))
                {
                    obsRow = 11;
                    worksheet.Cell(currentRow, 9).Value = "Cod_Cur";
                    worksheet.Cell(currentRow, 10).Value = "Vez";
                }

                worksheet.Cell(currentRow, obsRow).Value = "Observación";
                #endregion

                #region Body
                foreach (var item in (List<Domain.Entities.MatriculaObsEntity>)Session["MATRICULA_RESPONSE"])
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodRC);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodAlu);
                    worksheet.Cell(currentRow, 3).Value = item.I_Anio;
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_Periodo);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.C_EstMat);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.C_Ciclo);
                    worksheet.Cell(currentRow, 7).Value = item.B_Ingresante.HasValue ? (item.B_Ingresante.Value ? "T" : "F") : null;
                    worksheet.Cell(currentRow, 8).Value = item.I_CredDesaprob;
                    
                    if (tipoAlumno.Equals(TipoAlumno.Pregrado))
                    {
                        worksheet.Cell(currentRow, 9).SetValue<string>(item.C_CodCurso);
                        worksheet.Cell(currentRow, 10).Value = item.I_Vez;   
                    }

                    worksheet.Cell(currentRow, obsRow).SetValue<string>(item.T_Message);
                }
                #endregion

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de alumnos.xlsx");
                }
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult CargarArchivoMulta(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMultasPorNoVotar(Server.MapPath("~/Upload/MultaNoVotar/"), file, WebSecurity.CurrentUserId);

            var response = Mapper.MultaNoVotarResponse_To_Response(result);

            Session["MULTAS_SIN_REGISTRAR_RESPONSE"] = result.MultasSinRegistrar;

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [Route("operaciones/cargar-multas-pregrado/resultado")]
        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        public ActionResult DescargarMultasSinRegistrar()
        {
            if (Session["MULTAS_SIN_REGISTRAR_RESPONSE"] == null)
                return RedirectToAction("cargar-estudiantes", "operaciones");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Students");
                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Año";
                worksheet.Cell(currentRow, 2).Value = "P";
                worksheet.Cell(currentRow, 3).Value = "Cod_alu";
                worksheet.Cell(currentRow, 4).Value = "Cod_rc";
                worksheet.Cell(currentRow, 5).Value = "Observación";
                #endregion

                #region Body
                foreach (var item in (List<Domain.Entities.MultaNoVotarSinRegistrarEntity>)Session["MULTAS_SIN_REGISTRAR_RESPONSE"])
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).Value = item.I_Anio;
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_Periodo);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodAlu);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodRC);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_Message);
                }
                #endregion

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de multas.xlsx");
                }
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONSULTA + ", " + RoleNames.TESORERIA + ", " + RoleNames.DEPENDENCIA)]
        [Route("consulta/estudiantes")]
        public ActionResult Consulta(ConsultaObligacionEstudianteViewModel model)
        {
            var userId = usersModel.Find()
                .Where(u => u.UserName.Equals(User.Identity.Name, StringComparison.InvariantCultureIgnoreCase))
                .First().UserId;

            var user = usersModel.Find(userId.Value);

            bool mostrarReporteObligaciones = true;

            if (user.RoleName.Equals(RoleNames.DEPENDENCIA))
            {
                model.dependencia = user.DependenciaId;

                model.tipoEstudio = (model.dependencia == DependenciaEUPG.ID) ? TipoEstudio.Posgrado : TipoEstudio.Pregrado;

                mostrarReporteObligaciones = false;
            }

            var listaDependencias = programasClientFacade.GetDependencias(model.tipoEstudio, model.dependencia);

            model.codFac = (user.RoleName.Equals(RoleNames.DEPENDENCIA)) ? listaDependencias.First().Value : model.codFac;

            if (model.anio.HasValue)
            {
                switch (model.tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        model.resultado = reportePregradoServiceFacade.EstadoObligacionAlumnos(model);
                        break;

                    case TipoEstudio.Posgrado:
                        model.resultado = reportePosgradoServiceFacade.EstadoObligacionAlumnos(model);
                        break;
                }
            }

            ViewBag.Title = "Consulta de Estudiantes";

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", model.anio.HasValue ? model.anio.Value : DateTime.Now.Year);
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay", model.periodo);
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(model.dependencia), "Value", "TextDisplay", model.tipoEstudio);
            ViewBag.Dependencias = new SelectList(listaDependencias, "Value", "TextDisplay", model.codFac);
            ViewBag.Escuelas = new SelectList(programasClientFacade.GetEscuelas(model.codFac), "Value", "TextDisplay", model.codEsc);
            ViewBag.Especialidades = new SelectList(programasClientFacade.GetEspecialidades(model.codFac, model.codEsc), "Value", "TextDisplay", model.codRc);

            ViewBag.TipoAlumno = new SelectList(generalServiceFacade.Listar_TipoAlumno(), "Value", "TextDisplay", model.esIngresante);
            ViewBag.ExistenciaObligaciones = new SelectList(generalServiceFacade.Listar_CondicionExistenciaObligaciones(), "Value", "TextDisplay", model.obligacionGenerada);
            ViewBag.EstadoPagoObligaciones = new SelectList(generalServiceFacade.Listar_CondicionPagoObligacion(), "Value", "TextDisplay", model.estaPagado);

            ViewBag.FiltroDependencias = (model.tipoEstudio == TipoEstudio.Posgrado || model.dependencia.HasValue) ? null : "TODOS";
            ViewBag.MostrarReporteObligaciones = mostrarReporteObligaciones;

            return View("Consulta", model);
        }

        [Route("consulta/estudiantes/descarga")]
        public ActionResult DescargaConsulta(ConsultaObligacionEstudianteViewModel model)
        {
            if (!model.anio.HasValue)
            {
                return RedirectToAction("Consulta", "Estudiantes");
            }

            var userId = usersModel.Find()
                .Where(u => u.UserName.Equals(User.Identity.Name, StringComparison.InvariantCultureIgnoreCase))
                .First().UserId;

            var user = usersModel.Find(userId.Value);

            if (user.RoleName.Equals(RoleNames.DEPENDENCIA))
            {
                model.dependencia = user.DependenciaId;

                model.tipoEstudio = (model.dependencia == DependenciaEUPG.ID) ? TipoEstudio.Posgrado : TipoEstudio.Pregrado;
            }

            switch (model.tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    model.resultado = reportePregradoServiceFacade.EstadoObligacionAlumnos(model);
                    break;

                case TipoEstudio.Posgrado:
                    model.resultado = reportePosgradoServiceFacade.EstadoObligacionAlumnos(model);
                    break;
            }

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Obligaciones");

                worksheet.Column("A").Width = 14;
                worksheet.Column("B").Width = 30;
                worksheet.Column("C").Width = 14;
                worksheet.Columns("D:E").Width = 30;
                worksheet.Columns("F:M").Width = 14;
                worksheet.Columns("N:P").Width = 15;

                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Cod.Alumno";
                worksheet.Cell(currentRow, 2).Value = "Nom.Alumno";
                worksheet.Cell(currentRow, 3).Value = "CodRc";
                worksheet.Cell(currentRow, 4).Value = "Facultad";                
                worksheet.Cell(currentRow, 5).Value = "Especialidad";
                worksheet.Cell(currentRow, 6).Value = "Tipo Alumno";
                worksheet.Cell(currentRow, 7).Value = "Año";
                worksheet.Cell(currentRow, 8).Value = "Periodo";
                worksheet.Cell(currentRow, 9).Value = "Cuota Pago";
                worksheet.Cell(currentRow, 10).Value = "Monto Oblig";
                worksheet.Cell(currentRow, 11).Value = "Fec.Vencto";
                worksheet.Cell(currentRow, 12).Value = "Estado";
                worksheet.Cell(currentRow, 13).Value = "Monto Pagado";
                worksheet.Cell(currentRow, 14).Value = "Fecha Pago";
                worksheet.Cell(currentRow, 15).Value = "Fec.Creación";
                worksheet.Cell(currentRow, 16).Value = "Ultima Modificación";
                #endregion

                #region Body
                foreach (var item in model.resultado)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodAlu);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.T_ApellidosNombres);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_RcCod);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.T_FacDesc);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_DenomProg);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.T_EsIngresante);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.I_Anio.ToString());
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.T_Periodo);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.T_ProcesoDesc);
                    worksheet.Cell(currentRow, 10).SetValue<decimal?>(item.I_MontoOblig);
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.T_FecVencto);
                    worksheet.Cell(currentRow, 12).SetValue<string>(item.T_Pagado);
                    worksheet.Cell(currentRow, 13).SetValue<decimal?>(item.I_MontoOblig == null ? null : item.I_MontoPagadoActual);
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.T_FecPagos);
                    worksheet.Cell(currentRow, 15).SetValue<DateTime?>(item.D_FecCre);
                    worksheet.Cell(currentRow, 16).SetValue<DateTime?>(item.D_FecMod);
                }
                #endregion

                worksheet.Range(worksheet.Cell(2, 10), worksheet.Cell(currentRow, 10)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;
                worksheet.Range(worksheet.Cell(2, 13), worksheet.Cell(currentRow, 13)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Consulta Obligaciones de Estudiantes.xlsx");
                }
            }
        }
    }
}