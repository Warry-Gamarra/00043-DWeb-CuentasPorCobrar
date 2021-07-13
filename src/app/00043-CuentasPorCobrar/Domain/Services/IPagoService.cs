using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IPagoService
    {
        bool ValidarCodOperacion(string C_CodOperacion, int I_EntidadFinanID, DateTime? D_FecPago);
        void GrabarRegistroArchivo(string fileName, string urlFile, int rowsCount, int entidadFinanID, int tipoArchivoID, int currentUserId);
        Response AnularRegistroPago(int pagoProcesId, int currentUserId, DateTime fecUpdate);
        Response GrabarNroSiafPago(int pagoProcesId, int nroSiaf, int currentUserId, DateTime fecUpdate);
        PagoEntity ObtenerDatosPago(int pagoProcesId);
        List<PagoEntity> ListarPagosRegistrados(DateTime? fecIni, DateTime? fecFin, int? dependenciaId, int? entRecaudaId);
        List<PagoEntity> BuscarPagoRegistrado(int entRecaudaId, string codOperacion);
        IEnumerable<ArchivoImportadoDTO> ListarArchivosImportados(TipoArchivoEntFinan tipoArchivo);
    }
}
