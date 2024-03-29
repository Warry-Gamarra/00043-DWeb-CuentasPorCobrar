﻿using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.Results;
using System.Xml.XPath;

namespace WebApp.Models.Facades
{
    public class ObligacionServiceFacade : IObligacionServiceFacade
    {
        private IObligacionService _obligacionService;
        private IProcesoService _procesoService;
        private ICatalogoService _catalogoService;
        private IEstudianteService _estudianteService;
        private ConceptoPagoService _conceptoPagoService;

        private const string C_NivelPregrado = "1";
        private const string C_NivelMaestria = "2";
        private const string C_NivelDoctorado = "3";
        private const string C_NivelSegundaEspecialidad = "4";
        private const string C_NivelResidentado = "5";

        private const string C_TipoAlumnoIngresante = "2";
        private const string C_TipoAlumnoRegular = "1";

        public ObligacionServiceFacade()
        {
            _obligacionService = new ObligacionService();
            _procesoService = new ProcesoService();
            _catalogoService = new CatalogoService();
            _estudianteService = new EstudianteService();
            _conceptoPagoService = new ConceptoPagoService();
        }

        public Response Generar_Obligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string codDependencia, bool? esIngresante, 
            bool sinObligaciones, bool soloAplicarExtmp, int currentUserID)
        {
            IEnumerable<Proceso> procesos = _procesoService.Listar_Procesos();
            string codFac = null, codGrado = null;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    procesos = procesos.Where(x => x.C_Nivel == C_NivelPregrado);

                    codFac = codDependencia;

                    break;

                case TipoEstudio.Posgrado:
                    procesos = procesos.Where(x => x.C_Nivel == C_NivelMaestria || x.C_Nivel == C_NivelDoctorado);

                    codGrado = codDependencia;

                    break;

                case TipoEstudio.Segunda_Especialidad:
                    procesos = procesos.Where(x => x.C_Nivel == C_NivelSegundaEspecialidad);
                    
                    codFac = codDependencia;
                    
                    break;

                case TipoEstudio.Residentado:
                    codFac = codDependencia;

                    procesos = procesos.Where(x => x.C_Nivel == C_NivelResidentado);

                    break;

                default:
                    throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
            }

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para " + tipoEstudio.ToString() + ".");
            }

            procesos = procesos.Where(x => x.I_Anio == anio);

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para el año " + anio.ToString() + ".");
            }

            var periodos = _catalogoService.Listar_Catalogo(Parametro.Periodo);

            var periodoDesc = periodos.Where(x => x.I_OpcionID == periodo).First().T_OpcionDesc;

            procesos = procesos.Where(x => x.I_Periodo == periodo);

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            int procesosSinConceptos = 0;

            procesos.ToList().ForEach(p => {
                if (_conceptoPagoService.Listar_ConceptoPago_Proceso_Habilitados(p.I_ProcesoID).Count == 0)
                {
                    procesosSinConceptos++;
                }
            });

            if (procesos.Count() == procesosSinConceptos)
            {
                throw new Exception("No existen Conceptos de Pago para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            IEnumerable<MatriculaDTO> matriculas = null;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    matriculas = _estudianteService.GetMatriculaPregrado(anio, periodo);

                    if (!String.IsNullOrEmpty(codFac))
                    {
                        matriculas = matriculas.Where(x => x.C_CodFac == codFac);
                    }
                    break;

                case TipoEstudio.Posgrado:
                    matriculas = _estudianteService.GetMatriculaPosgrado(anio, periodo);

                    if (!String.IsNullOrEmpty(codGrado))
                    {
                        matriculas = matriculas.Where(x => x.C_CodEsc == codGrado);
                    }

                    break;

                case TipoEstudio.Segunda_Especialidad:
                    matriculas = _estudianteService.GetMatriculaSegundaEspecialidad(anio, periodo);

                    if (!String.IsNullOrEmpty(codFac))
                    {
                        matriculas = matriculas.Where(x => x.C_CodFac == codFac);
                    }
                    break;

                case TipoEstudio.Residentado:
                    matriculas = _estudianteService.GetMatriculaResidentado(anio, periodo);

                    if (!String.IsNullOrEmpty(codFac))
                    {
                        matriculas = matriculas.Where(x => x.C_CodFac == codFac);
                    }
                    break;
            }

            if (matriculas.Count() == 0)
            {
                throw new Exception("No existen Alumnos para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    return _obligacionService.Generar_Obligaciones_Pregrado(anio, periodo, codFac, esIngresante, sinObligaciones, soloAplicarExtmp, currentUserID);

                case TipoEstudio.Posgrado:
                    return _obligacionService.Generar_Obligaciones_Posgrado(anio, periodo, codGrado, esIngresante, sinObligaciones, soloAplicarExtmp, currentUserID);
                default:
                    throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
            }
        }

        public Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, string nivel, int currentUserID)
        {
            TipoEstudio tipoEstudio;

            if (nivel == C_NivelPregrado)
            {
                tipoEstudio = TipoEstudio.Pregrado;
            }
            else if (nivel == C_NivelMaestria || nivel == C_NivelDoctorado)
            {
                tipoEstudio = TipoEstudio.Posgrado;
            }
            else if (nivel == C_NivelSegundaEspecialidad)
            {
                tipoEstudio = TipoEstudio.Segunda_Especialidad;
            }
            else if (nivel == C_NivelResidentado)
            {
                tipoEstudio = TipoEstudio.Residentado;
            }
            else
            {
                throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
            }

            var matricula = _estudianteService.GetMatricula(anio, periodo, codAlu, codRc);

            if (matricula == null)
            {
                throw new Exception("El alumno no se encuentra asignado en el período actual.");
            }

            string tipoAlumno = matricula.B_Ingresante.Value ? C_TipoAlumnoIngresante : C_TipoAlumnoRegular;

            IEnumerable<Proceso> procesos = _procesoService.Listar_Procesos().Where(x => x.C_Nivel == nivel && x.C_TipoAlumno == tipoAlumno);

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para " + tipoEstudio.ToString() + ".");
            }

            procesos = procesos.Where(x => x.I_Anio == anio);

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para el año " + anio.ToString() + ".");
            }

            var periodos = _catalogoService.Listar_Catalogo(Parametro.Periodo);

            var periodoDesc = periodos.Where(x => x.I_OpcionID == periodo).First().T_OpcionDesc;

            procesos = procesos.Where(x => x.I_Periodo == periodo);

            if (procesos.Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            int procesosSinConceptos = 0;

            procesos.ToList().ForEach(p =>
            {
                if (_conceptoPagoService.Listar_ConceptoPago_Proceso_Habilitados(p.I_ProcesoID).Count == 0)
                {
                    procesosSinConceptos++;
                }
            });

            if (procesos.Count() == procesosSinConceptos)
            {
                throw new Exception("No existen Conceptos de Pago para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    return _obligacionService.Generar_ObligacionesPregrado_PorAlumno(anio, periodo, codAlu, codRc, currentUserID);

                case TipoEstudio.Posgrado:
                    return _obligacionService.Generar_ObligacionesPosgrado_PorAlumno(anio, periodo, codAlu, codRc, currentUserID);

                default:
                    throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
            }
        }

        public List<ObligacionDetalleModel> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc)
        {
            var detalle = _obligacionService.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var result = detalle.Select(d => Mapper.ObligacionDetalleDTO_To_ObligacionDetalleModel(d)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc)
        {
            var cuotasPago = _obligacionService.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int? periodo, TipoEstudio tipoEstudio, string codDependencia)
        {
            var cuotasPago = _obligacionService.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, codDependencia);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }

        public IEnumerable<CtaDepoProcesoModel> Obtener_CtaDeposito_X_Periodo(int anio, int? periodo, TipoEstudio? tipoEstudio)
        {
            IEnumerable<CtaDepoProcesoModel> result;

            IEnumerable<CtaDepoProceso> ctasDeposito;

            if (tipoEstudio.HasValue)
            {
                switch (tipoEstudio.Value)
                {
                    case TipoEstudio.Pregrado:
                        ctasDeposito = _obligacionService.Obtener_CtaDeposito_X_Periodo(anio, periodo)
                            .Where(x => x.C_Nivel == C_NivelPregrado);
                        break;

                    case TipoEstudio.Posgrado:
                        ctasDeposito = _obligacionService.Obtener_CtaDeposito_X_Periodo(anio, periodo)
                            .Where(x => x.C_Nivel == C_NivelMaestria || x.C_Nivel == C_NivelDoctorado);
                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        ctasDeposito = _obligacionService.Obtener_CtaDeposito_X_Periodo(anio, periodo)
                            .Where(x => x.C_Nivel == C_NivelSegundaEspecialidad);
                        break;

                    case TipoEstudio.Residentado:
                        ctasDeposito = _obligacionService.Obtener_CtaDeposito_X_Periodo(anio, periodo)
                            .Where(x => x.C_Nivel == C_NivelResidentado);
                        break;

                    default:
                        throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
                }
            }
            else
            {
                ctasDeposito = _obligacionService.Obtener_CtaDeposito_X_Periodo(anio, periodo);
            }
            
            result = ctasDeposito.Select(x => Mapper.CtaDepoProceso_To_CtaDepoProcesoModel(x));

            return result;
        }

        public CuotaPagoModel Obtener_CuotaPago(int obligacionID)
        {
            var cuotaPago = _obligacionService.Obtener_CuotaPago(obligacionID);

            return (cuotaPago == null) ? null : Mapper.CuotaPagoDTO_To_CuotaPagoModel(cuotaPago);
        }

        public List<ObligacionDetalleModel> Obtener_DetalleObligacion_X_Obligacion(int idObligacion)
        {
            var detalle = _obligacionService.Obtener_DetalleObligacion_X_Obligacion(idObligacion);

            var result = detalle.Select(d => Mapper.ObligacionDetalleDTO_To_ObligacionDetalleModel(d)).ToList();

            return result;
        }

        public ObligacionDetalleModel Obtener_DetalleObligacion_X_ID(int idObligacionDet)
        {
            var detalle = _obligacionService.Obtener_DetalleObligacion_X_ID(idObligacionDet);

            var result = detalle == null ? null : Mapper.ObligacionDetalleDTO_To_ObligacionDetalleModel(detalle);

            return result;
        }

        public Response ActualizarMontoObligaciones(int obligacionAluDetID, decimal monto, int tipoDocumento, string documento, int userID)
        {
            Response result = _obligacionService.ActualizarMontoObligaciones(obligacionAluDetID, monto, tipoDocumento, documento, userID);

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(false);
            }

            return result;
        }

        public Response AnularObligacion(int obligacionID, int currentUserID)
        {
            return _obligacionService.AnularObligacion(obligacionID, currentUserID);
        }

        public List<Response> RegistrarAmpliacionCreditos(IEnumerable<AmpliacionCreditoModel> conceptosObligacion, int tipoDocumentoID, string descripcionDocumento, int currentUserID)
        {
            var generalResult = new List<Response>();
            Response result;

            try
            {
                if (conceptosObligacion != null && conceptosObligacion.Count() > 0)
                {
                    

                    var listaAgrupada = conceptosObligacion.GroupBy(x => new { x.procesoId, x.procesoDesc, x.matAluID, x.fechaVcto, x.sFechaVcto });

                    foreach (var obligacion in listaAgrupada)
                    {
                        var obligacionesRegistradas = _obligacionService.Obtener_ObligacionesAluCab(obligacion.Key.procesoId, obligacion.Key.matAluID);

                        if (obligacionesRegistradas.Any(x => x.D_FecVencto.Value.Date == obligacion.Key.fechaVcto.Date))
                        {
                            result = new Response()
                            {
                                Message = String.Format("Debe seleccionar una fecha de vencimiento diferente para \"{0} ({1})\".", obligacion.Key.procesoDesc, obligacion.Key.sFechaVcto),
                                Color = "danger"
                            };
                        }
                        else
                        {
                            var conceptos = obligacion.Select(x => new ConceptosObligacionType { concPagID = x.conceptoID, monto = x.monto });

                            result = _obligacionService.RegistrarAmpliacionCreditos(conceptos, obligacion.Key.procesoId, obligacion.Key.matAluID, obligacion.Key.fechaVcto,
                                tipoDocumentoID, descripcionDocumento, currentUserID);

                            result.Message = result.Value ? String.Format("Registro realizado con éxito para \"{0} ({1})\".", obligacion.Key.procesoDesc, obligacion.Key.sFechaVcto) : result.Message;

                            result.Color = result.Value ? "success" : "danger";
                        }

                        generalResult.Add(result);
                    }
                }
                else
                {
                    result = new Response()
                    {
                        Message = "No hay conceptos seleccionados.",
                        Color = "danger"
                    };

                    generalResult.Add(result);
                }
            }
            catch (Exception ex)
            {
                result = new Response()
                {
                    Message = ex.Message,
                    Color = "danger"
                };

                generalResult.Add(result);
            }

            return generalResult;
        }
    }
}