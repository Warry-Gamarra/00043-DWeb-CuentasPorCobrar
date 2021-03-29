using Domain.DTO;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.Facades
{
    public class ObligacionServiceFacade : IObligacionServiceFacade
    {
        private IObligacionService obligacionService;
        private IProcesoService _procesoService;
        private ICatalogoService _catalogoService;

        public ObligacionServiceFacade()
        {
            obligacionService = new ObligacionService();
            _procesoService = new ProcesoService();
            _catalogoService = new CatalogoService();
        }

        public Response Generar_Obligaciones_Pregrado(int anio, int periodo, string codFacultad, int currentUserID)
        {
            var procesos = _procesoService.Listar_Procesos();

            var periodos = _catalogoService.Listar_Catalogo(Parametro.Periodo);

            if (procesos.Where(x => x.I_Anio == anio).Count() == 0)
            {
                throw new Exception("No existen Cuotas de Pago para el año " + anio.ToString());
            }

            if (procesos.Where(x => x.I_Anio == anio && x.I_Periodo == periodo).Count() == 0)
            {
                var periodoDesc = periodos.Where(x => x.I_OpcionID == periodo).First().T_OpcionDesc;

                throw new Exception("No existen Cuotas de Pago para el período " + anio.ToString() + " - " + periodoDesc);
            }
            
            //var listaConceptos = listaProcesos.
            //if (NonSerializedAttribute existe Proceso ni Conceptos entoncves Faild) {
            //    _procesoService.Listar_Procesos().Where(x => x.I_Anio == anio);
            //}

            //Validar que exista al menos un alumno.

            return obligacionService.Generar_Obligaciones_Pregrado(anio, periodo, codFacultad, currentUserID);
        }

        public Response Generar_Obligaciones_Posgrado(int anio, int periodo, int currentUserID)
        {
            return obligacionService.Generar_Obligaciones_Posgrado(anio, periodo, currentUserID);
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

        public List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int periodo, TipoEstudio tipoEstudio, string codFac, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            var cuotasPago = obligacionService.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, codFac, fechaDesde, fechaHasta);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }
    }
}