using Domain.Entities;
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
        private IObligacionService _obligacionService;
        private IProcesoService _procesoService;
        private ICatalogoService _catalogoService;
        private IEstudianteService _estudianteService;
        private ConceptoPagoService _conceptoPagoService;

        private const string C_NivelPregrado = "1";
        private const string C_NivelMaestria = "2";
        private const string C_NivelDoctorado = "3";

        public ObligacionServiceFacade()
        {
            _obligacionService = new ObligacionService();
            _procesoService = new ProcesoService();
            _catalogoService = new CatalogoService();
            _estudianteService = new EstudianteService();
            _conceptoPagoService = new ConceptoPagoService();
        }

        public Response Generar_Obligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string codFacultad, int currentUserID)
        {
            IEnumerable<Proceso> procesos = _procesoService.Listar_Procesos();

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    procesos = procesos.Where(x => x.C_Nivel == C_NivelPregrado);
                    break;
                case TipoEstudio.Posgrado:
                    procesos = procesos.Where(x => x.C_Nivel == C_NivelMaestria || x.C_Nivel == C_NivelDoctorado);
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

            int procesoID = procesos.First().I_ProcesoID;

            var conceptosPago = _conceptoPagoService.Listar_ConceptoPago_Proceso_Habilitados(procesoID);

            if (conceptosPago.Count() == 0)
            {
                throw new Exception("No existen Conceptos de Pago para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            IEnumerable<MatriculaDTO> matriculas = null;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    matriculas = _estudianteService.GetMatriculaPregrado(anio, periodo);
                    break;

                case TipoEstudio.Posgrado:
                    matriculas = _estudianteService.GetMatriculaPosgrado(anio, periodo);
                    break;
            }

            if (matriculas.Count() == 0)
            {
                throw new Exception("No existen Alumnos para el período " + anio.ToString() + " - " + periodoDesc + ".");
            }

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    return _obligacionService.Generar_Obligaciones_Pregrado(anio, periodo, codFacultad, currentUserID);

                case TipoEstudio.Posgrado:
                    return _obligacionService.Generar_Obligaciones_Posgrado(anio, periodo, currentUserID);
                default:
                    throw new NotImplementedException("Ha ocurrido un error al identificar si el alumno es de Pregrado o Posgrado.");
            }
        }

        public Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
        {
            return _obligacionService.Generar_Obligaciones_PorAlumno(anio, periodo, codAlu, codRc, currentUserID);
        }

        public List<ObligacionDetalleModel> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc)
        {
            var detalle = _obligacionService.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var result = detalle.Select(d => Mapper.ObligacionDetalleDTO_To_ObligacionDetalleModel(d)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotaPago(int anio, int periodo, string codAlu, string codRc)
        {
            var cuotasPago = _obligacionService.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }

        public List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int periodo, TipoEstudio tipoEstudio, string codFac, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            var cuotasPago = _obligacionService.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, codFac, fechaDesde, fechaHasta);

            var result = cuotasPago.Select(c => Mapper.CuotaPagoDTO_To_CuotaPagoModel(c)).ToList();

            return result;
        }
    }
}