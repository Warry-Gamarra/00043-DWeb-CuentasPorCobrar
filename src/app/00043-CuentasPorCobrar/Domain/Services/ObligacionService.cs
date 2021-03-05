using Data;
using Data.Procedures;
using Data.Views;
using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public class ObligacionService
    {
        public Response Generar_Obligaciones_Pregrado(int anio, int periodo, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPregrado_X_Ciclo()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                I_UsuarioCre = currentUserID
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }

        public Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPregrado_X_Ciclo()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_CodAlu = codAlu,
                C_CodRc = codRc,
                I_UsuarioCre = currentUserID
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }

        public IEnumerable<ObligacionDetalleDTO> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc)
        {
            var detalle = VW_DetalleObligaciones.FindByAlumno(anio, periodo, codAlu, codRc);

            var result = detalle.Select(d => Mapper.VW_DetalleObligaciones_To_ObligacionDetalleDTO(d));

            return result;
        }

        public IEnumerable<CuotaPagoDTO> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc)
        {
            var cuotaPagos = VW_CuotasPago.FindByAlumno(anio, periodo, codAlu, codRc);

            var result = cuotaPagos.Select(c => Mapper.VW_CuotaPago_To_CuotaPagoDTO(c));

            return result;
        }
        
        public IEnumerable<CuotaPagoDTO> Obtener_CuotasPago_X_Proceso(int anio, int periodo, int tipoAlumno, int nivel)
        {
            var cuotaPagos = VW_CuotasPago.GetByProceso(anio, periodo, tipoAlumno, nivel);

            var result = cuotaPagos.Select(c => Mapper.VW_CuotaPago_To_CuotaPagoDTO(c));

            return result;
        }

        public IEnumerable<EspecialidadesPorAlumnoDTO> Obtener_Especialidades_X_Alumno(string codAlu)
        {
            var especialidades = VW_EspecialidadesPorAlumno.FindByAlumno(codAlu);

            var result = especialidades.Select(e => Mapper.VW_EspecialidadesPorAlumno_To_EspecialidadesPorAlumnoDTO(e));

            return result;
        }
    }
}
