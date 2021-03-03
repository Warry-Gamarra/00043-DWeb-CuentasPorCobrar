using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

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
                C_CodAlu = obligacionDetalleDTO.C_CodAlu,
                C_CodRc = obligacionDetalleDTO.C_CodRc,
                I_Anio = obligacionDetalleDTO.I_Anio,
                I_Periodo = obligacionDetalleDTO.I_Periodo,
                T_Periodo = obligacionDetalleDTO.T_Periodo,
                T_ConceptoDesc = obligacionDetalleDTO.T_ConceptoDesc,
                T_CatPagoDesc = obligacionDetalleDTO.T_CatPagoDesc,
                I_Monto = obligacionDetalleDTO.I_Monto,
                B_Pagado = obligacionDetalleDTO.B_Pagado,
                D_FecVencto = obligacionDetalleDTO.D_FecVencto,
                I_Prioridad = obligacionDetalleDTO.I_Prioridad
            };

            return obligacionDetalleModel;
        }

        public static CuotaPagoModel CuotaPagoDTO_To_CuotaPagoModel(CuotaPagoDTO cuotaPagoDTO)
        {
            var cuotaPagoModel = new CuotaPagoModel()
            {
                I_ProcesoID = cuotaPagoDTO.I_ProcesoID,
                I_Anio = cuotaPagoDTO.I_Anio,
                I_Periodo = cuotaPagoDTO.I_Periodo,
                C_CodAlu = cuotaPagoDTO.C_CodAlu,
                C_CodRc = cuotaPagoDTO.C_CodRc,
                T_Periodo = cuotaPagoDTO.T_Periodo,
                T_CatPagoDesc = cuotaPagoDTO.T_CatPagoDesc,
                I_MontoTotal = cuotaPagoDTO.I_MontoTotal,
                D_FecVencto = cuotaPagoDTO.D_FecVencto
            };

            return cuotaPagoModel;
        }
    }
}