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
                C_CodOperacion = obligacionDetalleDTO.C_CodOperacion,
                D_FecPago = obligacionDetalleDTO.D_FecPago,
                T_LugarPago = obligacionDetalleDTO.T_LugarPago,
                C_Moneda = obligacionDetalleDTO.C_Moneda,
                I_TipoObligacion = obligacionDetalleDTO.I_TipoObligacion,
                I_Nivel = obligacionDetalleDTO.I_Nivel,
                C_Nivel = obligacionDetalleDTO.C_Nivel,
                T_Nivel = obligacionDetalleDTO.T_Nivel,
                I_TipoAlumno = obligacionDetalleDTO.I_TipoAlumno,
                C_TipoAlumno = obligacionDetalleDTO.C_TipoAlumno,
                T_TipoAlumno = obligacionDetalleDTO.T_TipoAlumno
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
                B_Pagado = cuotaPagoDTO.B_Pagado,
                C_CodOperacion = cuotaPagoDTO.C_CodOperacion,
                D_FecPago = cuotaPagoDTO.D_FecPago,
                T_LugarPago = cuotaPagoDTO.T_LugarPago
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

        public static MatriculaEntity MatriculaReader_To_MatriculaEntity(Reader reader)
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

            return dataMatriculaType;
        }

        public static MatriculaEntity MatriculaReader_To_MatriculaEntity(IExcelDataReader reader)
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

            if (reader.FieldCount > 8)
            {
                if (reader.GetValue(9) != null)
                {
                    dataMatriculaType.B_ActObl = reader.GetValue(9).ToString().Equals("T", StringComparison.OrdinalIgnoreCase);
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
                C_EstMat = matriculaDTO.C_EstMat,
                C_Ciclo = matriculaDTO.C_Ciclo,
                B_Ingresante = matriculaDTO.B_Ingresante,
                I_CredDesaprob = matriculaDTO.I_CredDesaprob,
                B_Habilitado = matriculaDTO.B_Habilitado,
                C_Periodo = matriculaDTO.C_Periodo,
                T_Periodo = matriculaDTO.T_Periodo,
                T_DenomProg = matriculaDTO.T_DenomProg,
                T_ModIngDesc = matriculaDTO.T_ModIngDesc,
                B_TieneMultaPorNoVotar = matriculaDTO.B_TieneMultaPorNoVotar
            };

            return matriculaModel;
        }

        public static PagosGeneralesPorFechaViewModel PagoGeneralPorFechaDTO_To_PagosGeneralesPorFechaViewModel(PagoGeneralPorFechaDTO dto)
        {
            var result = new PagosGeneralesPorFechaViewModel()
            {
                I_ConceptoID = dto.I_ConceptoID,
                T_ConceptoPagoDesc = dto.T_ConceptoPagoDesc,
                I_MontoTotal = dto.I_MontoTotal
            };

            return result;
        }

        public static PagosPorFacultadYFechaViewModel PagoPorFacultadYFechaDTO_To_PagosPorFacultadYFechaViewModel(PagoPorFacultadYFechaDTO dto)
        {
            var result = new PagosPorFacultadYFechaViewModel()
            {
                C_CodFac = dto.C_CodFac,
                I_ConceptoID = dto.I_ConceptoID,
                T_ConceptoPagoDesc = dto.T_ConceptoPagoDesc,
                I_MontoTotal = dto.I_MontoTotal
            };

            return result;
        }

        public static PagoObligacionEntity PagoObligacionViewModel_To_PagoObligacionEntity(PagoObligacionViewModel model)
        {
            var result = new PagoObligacionEntity()
            {
                C_CodOperacion = model.codigoOperacion,
                T_NomDepositante = model.nombreAlumno,
                C_Referencia = model.codigoReferencia,
                D_FecPago = model.fechaPago.Value,
                I_Cantidad = model.cantidad,
                T_LugarPago = model.lugarPago,
                C_CodAlu = model.codigoAlumno,
                C_CodRc = model.codRc,
                C_Moneda = model.moneda,
                I_EntidadFinanID = model.idEntidadFinanciera
            };

            return result;
        }
    }
}