using Domain.Helpers;
using Domain.Entities;
using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

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
                T_CatPagoDesc = cuotaPagoDTO.T_CatPagoDesc,
                D_FecVencto = cuotaPagoDTO.D_FecVencto,
                C_Moneda = cuotaPagoDTO.C_Moneda,
                I_TipoObligacion = cuotaPagoDTO.I_TipoObligacion,
                C_Nivel = cuotaPagoDTO.C_Nivel,
                C_TipoAlumno = cuotaPagoDTO.C_TipoAlumno,
                I_MontoTotal = cuotaPagoDTO.I_MontoTotal
            };

            return cuotaPagoModel;
        }

        public static EspecialidadAlumnoModel AlumnoModel_To_EspecialidadAlumnoModel(AlumnoModel alumno)
        {
            var result = new EspecialidadAlumnoModel()
            {
                C_CodAlu = alumno.C_CodAlu,
                C_RcCod = alumno.C_RcCod,
                T_EspDesc = alumno.T_DenomProg
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
    }
}