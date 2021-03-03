using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class ObligacionFacade
    {
        private ObligacionService obligacionService;

        public ObligacionFacade()
        {
            obligacionService = new ObligacionService();
        }

        public Response Generar_Obligaciones_Pregrado(int anio, int periodo, int currentUserID)
        {
            return obligacionService.Generar_Obligaciones_Pregrado(anio, periodo, currentUserID);
        }

        public Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
        {
            return obligacionService.Generar_Obligaciones_PorAlumno(anio, periodo, codAlu, codRc, currentUserID);
        }

        public List<ObligacionDetalleModel> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc)
        {
            var detalle = obligacionService.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var result = detalle.Select(d => Mapper.ObligacionDetalleDTO_To_ObligacionDetalleModel(d)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotaPago(int anio, int periodo, string codAlu, string codRc)
        {
            var cuotasPago = obligacionService.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int periodo, int tipoAlumno, int nivel)
        {
            var cuotasPago = obligacionService.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoAlumno, nivel);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }
    }
}