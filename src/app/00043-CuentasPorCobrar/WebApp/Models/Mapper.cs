using Domain.Helpers;
using Domain.Entities;
using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;
using NDbfReader;
using ExcelDataReader;

namespace WebApp.Models
{
    public static class Mapper
    {
        public static Response DataMatriculaResponse_To_Response(DataMatriculaResponse dataMatriculaResponse)
        {
            var response = new Response()
            {
                Value = dataMatriculaResponse.Success,
                Message = dataMatriculaResponse.Message
            };

            return response;
        }

        public static ObligacionDetalleModel ObligacionDetalleDTO_To_ObligacionDetalleModel(ObligacionDetalleDTO obligacionDetalleDTO)
        {
            var obligacionDetalleModel = new ObligacionDetalleModel()
            {
                I_ObligacionAluDetID = obligacionDetalleDTO.I_ObligacionAluDetID,
                I_ObligacionAluID = obligacionDetalleDTO.I_ObligacionAluID,
                I_ProcesoID = obligacionDetalleDTO.I_ProcesoID,
                N_CodBanco = obligacionDetalleDTO.N_CodBanco,
                C_CodAlu = obligacionDetalleDTO.C_CodAlu,
                C_CodRc = obligacionDetalleDTO.C_CodRc,
                C_CodFac = obligacionDetalleDTO.C_CodFac,
                T_Nombre = obligacionDetalleDTO.T_Nombre,
                T_ApePaterno = obligacionDetalleDTO.T_ApePaterno,
                T_ApeMaterno = obligacionDetalleDTO.T_ApeMaterno,
                I_Anio = obligacionDetalleDTO.I_Anio,
                I_Periodo = obligacionDetalleDTO.I_Periodo,
                C_Periodo = obligacionDetalleDTO.C_Periodo,
                T_Periodo = obligacionDetalleDTO.T_Periodo,
                T_ProcesoDesc = obligacionDetalleDTO.T_ProcesoDesc,
                T_ConceptoDesc = obligacionDetalleDTO.T_ConceptoDesc,
                T_CatPagoDesc = obligacionDetalleDTO.T_CatPagoDesc,
                I_Monto = obligacionDetalleDTO.I_Monto,
                B_Pagado = obligacionDetalleDTO.B_Pagado,
                D_FecVencto = obligacionDetalleDTO.D_FecVencto,
                I_Prioridad = obligacionDetalleDTO.I_Prioridad,
                C_Moneda = obligacionDetalleDTO.C_Moneda,
                I_TipoObligacion = obligacionDetalleDTO.I_TipoObligacion,
                I_Nivel = obligacionDetalleDTO.I_Nivel,
                C_Nivel = obligacionDetalleDTO.C_Nivel,
                T_Nivel = obligacionDetalleDTO.T_Nivel,
                I_TipoAlumno = obligacionDetalleDTO.I_TipoAlumno,
                C_TipoAlumno = obligacionDetalleDTO.C_TipoAlumno,
                T_TipoAlumno = obligacionDetalleDTO.T_TipoAlumno,
                I_TipoDocumento = obligacionDetalleDTO.I_TipoDocumento,
                T_DescDocumento = obligacionDetalleDTO.T_DescDocumento
            };

            return obligacionDetalleModel;
        }

        public static CuotaPagoModel CuotaPagoDTO_To_CuotaPagoModel(CuotaPagoDTO cuotaPagoDTO)
        {
            var cuotaPagoModel = new CuotaPagoModel()
            {
                I_NroOrden = cuotaPagoDTO.I_NroOrden,
                I_ObligacionAluID = cuotaPagoDTO.I_ObligacionAluID,
                I_ProcesoID = cuotaPagoDTO.I_ProcesoID,
                N_CodBanco = cuotaPagoDTO.N_CodBanco,
                C_CodAlu = cuotaPagoDTO.C_CodAlu,
                C_CodRc = cuotaPagoDTO.C_CodRc,
                C_CodFac = cuotaPagoDTO.C_CodFac,
                C_CodEsc = cuotaPagoDTO.C_CodEsc,
                T_Nombre = cuotaPagoDTO.T_Nombre,
                T_ApePaterno = cuotaPagoDTO.T_ApePaterno,
                T_ApeMaterno = cuotaPagoDTO.T_ApeMaterno,
                I_Anio = cuotaPagoDTO.I_Anio,
                I_Periodo = cuotaPagoDTO.I_Periodo,
                C_Periodo = cuotaPagoDTO.C_Periodo,
                T_Periodo = cuotaPagoDTO.T_Periodo,
                T_ProcesoDesc = cuotaPagoDTO.T_ProcesoDesc,
                D_FecVencto = cuotaPagoDTO.D_FecVencto,
                I_Prioridad = cuotaPagoDTO.I_Prioridad,
                C_Moneda = cuotaPagoDTO.C_Moneda,
                C_Nivel = cuotaPagoDTO.C_Nivel,
                C_TipoAlumno = cuotaPagoDTO.C_TipoAlumno,
                I_MontoOblig = cuotaPagoDTO.I_MontoOblig,
                I_MontoPagadoActual = cuotaPagoDTO.I_MontoPagadoActual,
                B_Pagado = cuotaPagoDTO.B_Pagado,
                D_FecCre = cuotaPagoDTO.D_FecCre,
                C_CodServicio = cuotaPagoDTO.C_CodServicio,
                T_FacDesc = cuotaPagoDTO.T_FacDesc,
                T_DenomProg = cuotaPagoDTO.T_DenomProg
            };

            return cuotaPagoModel;
        }

        public static EspecialidadAlumnoModel AlumnoModel_To_EspecialidadAlumnoModel(AlumnoModel alumno)
        {
            var result = new EspecialidadAlumnoModel()
            {
                C_CodAlu = alumno.C_CodAlu,
                C_RcCod = alumno.C_RcCod,
                T_EspDesc = alumno.T_DenomProg,
                N_Grado = alumno.N_Grado
            };

            return result;
        }

        public static SelectViewModel CatalogoOpcionEntity_To_SelectViewModel(CatalogoOpcionEntity catalogoOpcionEntity)
        {
            SelectViewModel selectViewModel = new SelectViewModel()
            {
                Value = catalogoOpcionEntity.I_OpcionID.ToString(),
                TextDisplay = catalogoOpcionEntity.T_OpcionDesc.ToUpper()
            };

            return selectViewModel;
        }

        public static MatriculaEntity MatriculaReader_To_MatriculaEntity(TipoAlumno tipoAlumno, Reader reader)
        {
            var dataMatriculaType = new MatriculaEntity()
            {
                C_CodRC = reader.GetString("COD_RC"),
                C_CodAlu = reader.GetString("COD_ALU"),
                I_Anio = reader.GetInt32("ANO"),
                C_Periodo = reader.GetString("P"),
                C_EstMat = reader.GetString("EST_MAT"),
                C_Ciclo = reader.GetString("NIVEL"),
                B_Ingresante = reader.GetBoolean("ES_INGRESA"),
                I_CredDesaprob = reader.GetInt32("CRED_DESAP")
            };

            if (tipoAlumno.Equals(TipoAlumno.Pregrado))
            {
                dataMatriculaType.C_CodCurso = reader.GetString("COD_CUR");
                dataMatriculaType.I_Vez = reader.GetInt32("VEZ");
            }

            return dataMatriculaType;
        }

        public static MatriculaEntity MatriculaReader_To_MatriculaEntity(TipoAlumno tipoAlumno, IExcelDataReader reader)
        {
            string stringValue; int intValue;

            var dataMatriculaType = new MatriculaEntity()
            {
                C_CodRC = reader.GetValue(0)?.ToString(),
                C_CodAlu = reader.GetValue(1)?.ToString(),
                C_Periodo = reader.GetValue(3)?.ToString(),
                C_EstMat = reader.GetValue(4)?.ToString(),
                C_Ciclo = reader.GetValue(5)?.ToString()
            };

            if (reader.GetValue(2) != null)
            {
                stringValue = reader.GetValue(2).ToString();

                if (int.TryParse(stringValue, out intValue))
                    dataMatriculaType.I_Anio = intValue;
            }

            if (reader.GetValue(6) != null)
            {
                stringValue = reader.GetValue(6).ToString();

                if (stringValue.Equals("T", StringComparison.OrdinalIgnoreCase))
                    dataMatriculaType.B_Ingresante = true;

                if (stringValue.Equals("F", StringComparison.OrdinalIgnoreCase))
                    dataMatriculaType.B_Ingresante = false;
            }

            if (reader.GetValue(7) != null)
            {
                stringValue = reader.GetValue(7).ToString();

                if (stringValue.Trim() == "")
                    dataMatriculaType.I_CredDesaprob = 0;
                else if (int.TryParse(stringValue, out intValue))
                    dataMatriculaType.I_CredDesaprob = intValue;
            }
            else
            {
                dataMatriculaType.I_CredDesaprob = 0;
            }

            if (tipoAlumno.Equals(TipoAlumno.Pregrado))
            {
                dataMatriculaType.C_CodCurso = reader.GetValue(8)?.ToString();

                if (reader.GetValue(9) != null)
                {
                    stringValue = reader.GetValue(9).ToString();

                    if (stringValue.Trim() == "")
                        dataMatriculaType.I_Vez = 1;
                    else if (int.TryParse(stringValue, out intValue))
                        dataMatriculaType.I_Vez = intValue;
                }
                else
                {
                    dataMatriculaType.I_Vez = 1;
                }
            }
            
            return dataMatriculaType;
        }

        public static CtaDepoProcesoModel CtaDepoProceso_To_CtaDepoProcesoModel(CtaDepoProceso ctaDepoProceso)
        {
            var model = new CtaDepoProcesoModel()
            {
                I_CtaDepoProID = ctaDepoProceso.I_CtaDepoProID,
                I_EntidadFinanID = ctaDepoProceso.I_EntidadFinanID,
                T_EntidadDesc = ctaDepoProceso.T_EntidadDesc,
                I_CtaDepositoID = ctaDepoProceso.I_CtaDepositoID,
                C_NumeroCuenta = ctaDepoProceso.C_NumeroCuenta,
                T_DescCuenta = ctaDepoProceso.T_DescCuenta,
                I_ProcesoID = ctaDepoProceso.I_ProcesoID,
                T_ProcesoDesc = ctaDepoProceso.T_ProcesoDesc,
                I_Prioridad = ctaDepoProceso.I_Prioridad,
                I_Anio = ctaDepoProceso.I_Anio,
                I_Periodo = ctaDepoProceso.I_Periodo,
                C_Periodo = ctaDepoProceso.C_Periodo,
                T_PeriodoDesc = ctaDepoProceso.T_PeriodoDesc,
                I_Nivel = ctaDepoProceso.I_Nivel,
                C_Nivel = ctaDepoProceso.C_Nivel,
                B_Habilitado = ctaDepoProceso.B_Habilitado
            };
            return model;
        }

        public static AlumnoMultaNoVotarEntity MatriculaReader_To_AlumnoMultaNoVotarEntity(IExcelDataReader reader)
        {
            string stringValue; int intValue;

            var alumnoSinVotoEntity = new AlumnoMultaNoVotarEntity()
            {
                C_Periodo = reader.GetValue(1)?.ToString(),
                C_CodAlu = reader.GetValue(2)?.ToString(),
                C_CodRC = reader.GetValue(3)?.ToString()
            };

            if (reader.GetValue(0) != null)
            {
                stringValue = reader.GetValue(0).ToString();

                if (int.TryParse(stringValue, out intValue))
                    alumnoSinVotoEntity.I_Anio = intValue;
            }

            return alumnoSinVotoEntity;
        }

        public static Response MultaNoVotarResponse_To_Response(MultaNoVotarResponse multaNoVotarResponse)
        {
            var response = new Response()
            {
                Value = multaNoVotarResponse.Success,
                Message = multaNoVotarResponse.Message
            };

            return response;
        }

        public static MatriculaModel MatriculaDTO_To_MatriculaModel(MatriculaDTO matriculaDTO)
        {
            var matriculaModel = new MatriculaModel()
            {
                I_MatAluID = matriculaDTO.I_MatAluID,
                C_CodAlu = matriculaDTO.C_CodAlu,
                C_RcCod = matriculaDTO.C_RcCod,
                T_Nombre = matriculaDTO.T_Nombre,
                T_ApePaterno = matriculaDTO.T_ApePaterno,
                T_ApeMaterno = matriculaDTO.T_ApeMaterno,
                N_Grado = matriculaDTO.N_Grado,
                I_Anio = matriculaDTO.I_Anio,
                I_Periodo = matriculaDTO.I_Periodo,
                C_CodFac = matriculaDTO.C_CodFac,
                T_FacDesc = matriculaDTO.T_FacDesc,
                C_CodEsc = matriculaDTO.C_CodEsc,
                T_EscDesc = matriculaDTO.T_EscDesc,
                C_EstMat = matriculaDTO.C_EstMat,
                C_Ciclo = matriculaDTO.C_Ciclo,
                B_Ingresante = matriculaDTO.B_Ingresante,
                I_CredDesaprob = matriculaDTO.I_CredDesaprob,
                B_Habilitado = matriculaDTO.B_Habilitado,
                C_Periodo = matriculaDTO.C_Periodo,
                T_Periodo = matriculaDTO.T_Periodo,
                T_DenomProg = matriculaDTO.T_DenomProg,
                C_CodModIng = matriculaDTO.C_CodModIng,
                T_ModIngDesc = matriculaDTO.T_ModIngDesc,
                B_TieneMultaPorNoVotar = matriculaDTO.B_TieneMultaPorNoVotar
            };

            return matriculaModel;
        }

        public static PagoObligacionEntity PagoObligacionViewModel_To_PagoObligacionEntity(PagoObligacionViewModel model)
        {
            var result = new PagoObligacionEntity()
            {
                C_CodOperacion = model.codigoOperacion,
                T_NomDepositante = model.nombreAlumno,
                C_Referencia = model.codigoReferencia,
                D_FecPago = model.fechaPagoObl,
                I_Cantidad = model.cantidad,
                T_LugarPago = model.lugarPago,
                C_CodAlu = model.codigoAlumno,
                C_CodRc = model.codRc,
                C_Moneda = model.moneda,
                I_EntidadFinanID = model.idEntidadFinanciera,
                I_CtaDepositoID = model.idCtaDeposito,
                I_MontoPago = model.I_MontoPago,
                I_InteresMora = model.I_InteresMora
            };

            return result;
        }

        public static ArchivoImportadoViewModel ArchivoImportadoDTO_To_ArchivoImportadoViewModel(ArchivoImportadoDTO dto)
        {
            var result = new ArchivoImportadoViewModel()
            {
                TipoArchivo = TipoArchivoEntFinan.Recaudacion_Obligaciones,
                EntidadRecaudadora = dto.T_EntidadDesc,
                FileName = dto.T_NomArchivo,
                UrlFile = dto.T_UrlArchivo,
                FecCarga = dto.D_FecCre.Value
            };

            return result;
        }

        public static EstadoObligacionViewModel EstadoObligacionDTO_To_EstadoObligacionViewModel(EstadoObligacionDTO dto)
        {
            var result = new EstadoObligacionViewModel()
            {
                I_MatAluID = dto.I_MatAluID,
                I_ObligacionAluID = dto.I_ObligacionAluID,
                C_CodAlu = dto.C_CodAlu,
                C_RcCod = dto.C_RcCod,
                T_Nombre = dto.T_Nombre,
                T_ApePaterno = dto.T_ApePaterno,
                T_ApeMaterno = dto.T_ApeMaterno,
                N_Grado = dto.N_Grado,
                C_CodFac = dto.C_CodFac,
                T_FacDesc = dto.T_FacDesc,
                C_CodEsc = dto.C_CodEsc,
                T_EscDesc = dto.T_EscDesc,
                T_DenomProg = dto.T_DenomProg,
                B_Ingresante = dto.B_Ingresante,
                I_CredDesaprob = dto.I_CredDesaprob,
                I_Anio = dto.I_Anio,
                T_Periodo = dto.T_Periodo,
                T_ProcesoDesc = dto.T_ProcesoDesc,
                I_MontoOblig = dto.I_MontoOblig,
                D_FecVencto = dto.D_FecVencto,
                B_Pagado = dto.B_Pagado,
                I_MontoPagadoActual = dto.I_MontoPagadoActual,
                D_FecCre = dto.D_FecCre,
                D_FecMod = dto.D_FecMod
            };

            return result;
        }

        public static PagoTasaEntity PagoTasaViewModel_To_PagoTasaEntity(PagoTasaViewModel model)
        {
            var result = new PagoTasaEntity()
            {
                C_CodDepositante = model.codigoDepositante,
                T_NomDepositante = model.nombreDepositante,
                C_CodOperacion = model.codigoOperacion,
                T_Referencia = model.codigoReferencia,
                I_EntidadFinanID = model.idEntidadFinanciera,
                I_CtaDepositoID = model.idCtaDeposito,
                D_FecPago = model.fechaPagoTasa,
                I_Cantidad = model.cantidad,
                C_Moneda = model.moneda,
                I_MontoPago = model.I_MontoPago,
                I_InteresMora = 0,
                T_LugarPago = model.lugarPago,
                T_InformacionAdicional = null
            };

            return result;
        }

        public static PagoTasaModel PagoTasaDTO_To_PagoTasaModel(PagoTasaDTO dto)
        {
            var model = new PagoTasaModel()
            {
                I_EntidadFinanID = dto.I_EntidadFinanID,
                T_EntidadDesc = dto.T_EntidadDesc,
                I_CtaDepositoID = dto.I_CtaDepositoID,
                C_NumeroCuenta = dto.C_NumeroCuenta,
                C_CodTasa = dto.C_CodTasa,
                T_ConceptoPagoDesc = dto.T_ConceptoPagoDesc,
                T_Clasificador = dto.T_Clasificador,
                C_CodClasificador = dto.C_CodClasificador,
                T_ClasificadorDesc = dto.T_ClasificadorDesc,
                M_Monto = dto.M_Monto,
                C_CodOperacion = dto.C_CodOperacion,
                C_CodDepositante = dto.C_CodDepositante,
                T_NomDepositante = dto.T_NomDepositante,
                D_FecPago = dto.D_FecPago,
                I_MontoPagado = dto.I_MontoPagado,
                I_InteresMoratorio = dto.I_InteresMoratorio,
                D_FecCre = dto.D_FecCre
            };

            return model;
        }

        public static PagoBancoObligacionViewModel PagoBancoObligacionDTO_ToPagoBancoObligacionViewModel(PagoBancoObligacionDTO dto)
        {
            var model = new PagoBancoObligacionViewModel()
            {
                I_PagoBancoID = dto.I_PagoBancoID,
                I_EntidadFinanID = dto.I_EntidadFinanID,
                T_EntidadDesc = dto.T_EntidadDesc,
                I_CtaDepositoID = dto.I_CtaDepositoID,
                C_NumeroCuenta = dto.C_NumeroCuenta,
                C_CodOperacion = dto.C_CodOperacion,
                C_CodDepositante = dto.C_CodDepositante,
                I_ObligacionAluID = dto.I_ObligacionAluID,
                I_MatAluID = dto.I_MatAluID,
                C_CodAlu = dto.C_CodAlu,
                T_NomDepositante = dto.T_NomDepositante,
                T_Nombre = dto.T_Nombre,
                T_ApePaterno = dto.T_ApePaterno,
                T_ApeMaterno = dto.T_ApeMaterno,
                D_FecPago = dto.D_FecPago,
                I_MontoPago = dto.I_MontoPago,
                I_InteresMora = dto.I_InteresMora,
                T_LugarPago = dto.T_LugarPago,
                D_FecCre = dto.D_FecCre,
                T_Observacion = dto.T_Observacion,
                I_CondicionPagoID = dto.I_CondicionPagoID,
                T_Condicion = dto.T_Condicion,
                I_MontoProcesado = dto.I_MontoProcesado,
                T_MotivoCoreccion = dto.T_MotivoCoreccion
            };

            return model;
        }
    }
}